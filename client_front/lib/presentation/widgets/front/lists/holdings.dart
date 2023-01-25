// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shimmer/shimmer.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class HoldingList extends StatefulWidget {
  final Iterable<Balance>? holdings;
  final ScrollController? scrollController;

  const HoldingList({
    this.scrollController,
    this.holdings,
    Key? key,
  }) : super(key: key);

  @override
  State<HoldingList> createState() => _HoldingList();
}

class _HoldingList extends State<HoldingList> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  int holdingCount = 0;
  bool showUSD = false;
  bool showPath = false;
  bool showSearchBar = false;
  Rate? rateUSD;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  // ignore: unused_element
  void _toggleUSD() {
    setState(() {
      if (pros.rates.primaryIndex
              .getOne(pros.securities.RVN, pros.securities.USD) ==
          null) {
        showUSD = false;
      } else {
        showUSD = !showUSD;
      }
    });
  }

  void _togglePath() {
    setState(() => showPath = !showPath);
  }

  Future<void> refresh(HoldingsViewCubit cubit) async {
    cubit.set(isSubmitting: true);
    setState(() {});
    await cubit.setHoldingViews(
      Current.wallet,
      pros.settings.chainNet,
      force: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final HoldingsViewCubit cubit =
        flutter_bloc.BlocProvider.of<HoldingsViewCubit>(context);
    if (cubit.state.ranWallet != Current.wallet ||
        cubit.state.ranChainNet != pros.settings.chainNet) {
      cubit.set(isSubmitting: true);
    }
    cubit.setHoldingViews(Current.wallet, pros.settings.chainNet);

    return GestureDetector(
        onTap: () => refresh(cubit), //FocusScope.of(context).unfocus(),
        child: flutter_bloc.BlocBuilder<HoldingsViewCubit, HoldingsViewState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, HoldingsViewState state) {
              if (state.isSubmitting == true) {
                return RefreshIndicator(
                    onRefresh: () => refresh(cubit),
                    child: components.empty.getAssetsPlaceholder(context,
                        scrollController: widget.scrollController,
                        count: max(holdingCount, 1),
                        holding: true));
              } else {
                if (state.holdingsViews.length == 1 &&
                    state.holdingsViews.first.sats == 0) {
                  // notice in new design used but empty wallet gets lumped in here too
                  if (pros.wallets.length == 1) {
                    return RefreshIndicator(
                        onRefresh: () => refresh(cubit),
                        child: ComingSoonPlaceholder(
                            scrollController: widget.scrollController,
                            header: 'Get Started',
                            message:
                                'Use the Import or Receive button to add ${pros.settings.chain.title} & assets to your wallet.'));
                  } else {
                    return RefreshIndicator(
                        onRefresh: () => refresh(cubit),
                        child: ComingSoonPlaceholder(
                            scrollController: widget.scrollController,
                            header: 'Empty Wallet',
                            message:
                                'This wallet has never been used before.\nClick "Receive" to get started.'));
                  }
                } else {
                  //if (state.holdingsViews.isNotEmpty) {
                  return RefreshIndicator(
                      onRefresh: () => refresh(cubit),
                      child: _holdingsView(
                        context,
                        cubit,
                        wallet: Current.wallet,
                        currentCrypto: pros.securities.currentCoin,
                      ));
                }
              }
            }));
  }

  void navigate(BalanceView balance, {Wallet? wallet}) {
    streams.app.wallet.asset.add(balance.symbol);
    Navigator.of(components.routes.routeContext!).pushNamed(
      '/transactions',
      arguments: <String, Object?>{'holding': balance, 'walletId': wallet?.id},
    );
  }

  Widget _holdingsView(
    BuildContext context,
    HoldingsViewCubit cubit, {
    required Security currentCrypto,
    Wallet? wallet,
    bool isEmpty = false,
  }) {
    final List<Widget> rvnHolding = <Widget>[];
    final List<Widget> assetHoldings = <Widget>[];
    final Padding searchBar = Padding(
        padding: const EdgeInsets.only(top: 1, bottom: 16, left: 16, right: 16),
        child: TextFieldFormatted(
            controller: searchController,
            //focusedErrorBorder: InputBorder.none,
            //errorBorder: InputBorder.none,
            //focusedBorder: InputBorder.none,
            //enabledBorder: InputBorder.none,
            //disabledBorder: InputBorder.none,
            contentPadding:
                const EdgeInsets.only(left: 16, top: 16, bottom: 16),
            autocorrect: false,
            textInputAction: TextInputAction.done,
            labelText: 'Search',
            suffixIcon: IconButton(
              icon: const Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: Icon(Icons.clear_rounded, color: AppColors.black38)),
              onPressed: () => setState(() {
                searchController.text = '';
                showSearchBar = false;
              }),
            ),
            onChanged: (_) => setState(() {}),
            onEditingComplete: () => setState(() => showSearchBar = false)));
    for (final AssetHolding holding in cubit.state.assetHoldings) {
      final ListTile thisHolding = ListTile(
          //dense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () async => onTap(wallet, holding),
          onLongPress: _togglePath,
          leading: leadingIcon(holding),
          title: title(holding, currentCrypto),
          trailing: services.developer.developerMode == true
              ? ((holding.symbol == currentCrypto.symbol) && !isEmpty
                  ? GestureDetector(
                      onTap: () =>
                          setState(() => showSearchBar = !showSearchBar),
                      child: searchController.text == ''
                          ? const Icon(Icons.search)
                          : const Icon(
                              Icons.search,
                              shadows: <Shadow>[
                                Shadow(
                                    color: AppColors.black12,
                                    offset: Offset(1, 1),
                                    blurRadius: 1),
                                Shadow(
                                    color: AppColors.black12,
                                    offset: Offset(1, 2),
                                    blurRadius: 2)
                              ],
                            ))
                  : null)
              : null);
      if (holding.symbol == currentCrypto.symbol) {
        //if (pros.securities.coinSymbols.contains(holding.symbol)) {
        rvnHolding.add(Column(
          children: <Widget>[
            thisHolding,
            if (showSearchBar && !isEmpty) searchBar,
          ],
        ));
        rvnHolding.add(const Divider(
          height: 1,
          indent: 70,
          endIndent: 0,
        ));
      } else {
        if (searchController.text == '' ||
            holding.symbol.contains(searchController.text.toUpperCase())) {
          assetHoldings.add(thisHolding);
          assetHoldings.add(const Divider(height: 1));
        }
      }
    }

    /// this case is when we haven't started downloading anything yet.
    if (rvnHolding.isEmpty && assetHoldings.isEmpty) {
      rvnHolding.add(Shimmer.fromColors(
          baseColor: AppColors.primaries[0],
          highlightColor: Colors.white,
          child: components.empty.holdingPlaceholder(context)));
    }

    final ListView listView = ListView(
        controller: widget.scrollController,
        physics: const ClampingScrollPhysics(),
        children: <Widget>[
          ...rvnHolding,
          ...assetHoldings,
          ...<Widget>[components.empty.blankNavArea(context)]
        ]);
    //if (services.developer.advancedDeveloperMode == true) {
    //  return RefreshIndicator(
    //    onRefresh: () async {
    //      streams.app.snack.add(Snack(message: 'Resyncing...'));
    //      await services.client.resetMemoryAndConnection();
    //      setState(() {});
    //    },
    //    child: listView,
    //  );
    //}
    return GestureDetector(
      onTap: () async {
        refresh(cubit);
      },
      child: listView,
    );
  }

  Future<void> onTap(Wallet? wallet, AssetHolding holding) async {
    final int unspentSum = <int>[
      ...<int>[
        for (Unspent x in Current.wallet.unspents
            .where((Unspent u) => u.symbol == holding.symbol))
          x.value
      ],
      ...<int>[0]
    ].sum;
    final int unspentBal = <int>[
      ...<int>[
        for (Balance x in Current.wallet.balances
            .where((Balance b) => b.security.symbol == holding.symbol))
          x.value
      ],
      ...<int>[0]
    ].sum;
    if (unspentSum != unspentBal) {
      await services.balance.recalculateAllBalances();
      setState(() {});
    }

    if (holding.length == 1) {
      navigate(holding.balance!, wallet: wallet);
    } else {
      SelectionItems(
        context,
        symbol: holding.symbol,
        names: <SelectionOption>[
          if (holding.main != null) SelectionOption.Main,
          if (holding.sub != null) SelectionOption.Sub,
          if (holding.subAdmin != null) SelectionOption.Sub_Admin,
          if (holding.admin != null) SelectionOption.Admin,
          if (holding.restricted != null) SelectionOption.Restricted,
          if (holding.restrictedAdmin != null) SelectionOption.Restricted_Admin,
          if (holding.qualifier != null) SelectionOption.Qualifier,
          if (holding.qualifierSub != null) SelectionOption.Sub_Qualifier,
          if (holding.nft != null) SelectionOption.NFT,
          if (holding.channel != null) SelectionOption.Channel,
        ],
        behaviors: <void Function()>[
          if (holding.main != null)
            () => navigate(holding.main!, wallet: wallet),
          if (holding.sub != null)
            () => navigate(holding.sub!, wallet: wallet), /////
          if (holding.subAdmin != null)
            () => navigate(holding.subAdmin!, wallet: wallet),
          if (holding.admin != null)
            () => navigate(holding.admin!, wallet: wallet),
          if (holding.restricted != null)
            () => navigate(holding.restricted!, wallet: wallet),
          if (holding.restrictedAdmin != null)
            () => navigate(holding.restrictedAdmin!, wallet: wallet),
          if (holding.qualifier != null)
            () => navigate(holding.qualifier!, wallet: wallet),
          if (holding.qualifierSub != null)
            () => navigate(holding.qualifierSub!, wallet: wallet),
          if (holding.nft != null)
            () => navigate(holding.nft!, wallet: wallet), /////
          if (holding.channel != null)
            () => navigate(holding.channel!, wallet: wallet),
        ],
        values: <String>[
          if (holding.main != null)
            services.conversion.securityAsReadable(
              holding.main!.sats,
              security: Security(
                symbol: holding.main!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.sub != null)
            services.conversion.securityAsReadable(
              holding.sub!.sats,
              security: Security(
                symbol: holding.sub!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.subAdmin != null)
            services.conversion.securityAsReadable(
              holding.subAdmin!.sats,
              security: Security(
                symbol: holding.subAdmin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.admin != null)
            services.conversion.securityAsReadable(
              holding.admin!.sats,
              security: Security(
                symbol: holding.admin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.restricted != null)
            services.conversion.securityAsReadable(
              holding.restricted!.sats,
              security: Security(
                symbol: holding.restricted!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.restrictedAdmin != null)
            services.conversion.securityAsReadable(
              holding.restrictedAdmin!.sats,
              security: Security(
                symbol: holding.restrictedAdmin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.qualifier != null)
            services.conversion.securityAsReadable(
              holding.qualifier!.sats,
              security: Security(
                symbol: holding.qualifier!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.qualifierSub != null)
            services.conversion.securityAsReadable(
              holding.qualifierSub!.sats,
              security: Security(
                symbol: holding.qualifierSub!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.nft != null)
            services.conversion.securityAsReadable(
              holding.nft!.sats,
              security: Security(
                symbol: holding.nft!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
          if (holding.channel != null)
            services.conversion.securityAsReadable(
              holding.channel!.sats,
              security: Security(
                symbol: holding.channel!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: showUSD,
            ),
        ],
      ).build();
    }
  }

  Widget leadingIcon(AssetHolding holding) => SizedBox(
          height: 40,
          width: 40,
          child: //Hero(
              //tag: holding.symbol.toLowerCase(),
              //child:
              components.icons.assetAvatar(
                  holding.admin != null
                      ? holding.adminSymbol!
                      : holding.restricted != null
                          ? holding.restrictedSymbol!
                          : holding.qualifier != null
                              ? holding.qualifierSymbol!
                              : holding.channel != null
                                  ? holding.channelSymbol!
                                  : holding.nft != null
                                      ? holding.nftSymbol!
                                      : holding.subAdmin != null
                                          ? holding.subAdminSymbol!
                                          : holding.sub != null
                                              ? holding.subSymbol!
                                              : holding.qualifierSub != null
                                                  ? holding.qualifierSubSymbol!
                                                  : holding.symbol,
                  net: pros.settings.net))
      //)
      ;

  Widget title(AssetHolding holding, Security currentCrypto) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Row(children: <Widget>[
          SizedBox(
              width: holding.symbol == currentCrypto.symbol
                  ? MediaQuery.of(context).size.width / 2
                  : MediaQuery.of(context).size.width - (16 + 40 + 16 + 16),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                    holding.symbol == currentCrypto.symbol
                        ? symbolName(holding.symbol)
                        : services.developer.developerMode && showPath
                            ? holding.symbol
                            : holding.last,
                    style: Theme.of(context).textTheme.bodyText1),
              )),
        ]),
        Text(
          holding.mainLength > 1 && holding.restricted != null
              ? <String>[
                  if (holding.main != null) 'Main',
                  if (holding.admin != null) 'Admin',
                  if (holding.restricted != null) 'Restricted',
                  if (holding.restrictedAdmin != null) 'Restricted Admin',
                ].join(', ')
              : services.conversion
                  .securityAsReadable(holding.balance?.sats ?? 0,
                      security: holding.balance == null
                          ? const Security(
                              symbol: 'unknown',
                              chain: Chain.none,
                              net: Net.test,
                            )
                          : Security(
                              symbol: holding.balance!.symbol,
                              chain: pros.settings.chain,
                              net: pros.settings.net,
                            ),
                      asUSD: showUSD),
          style: Theme.of(context)
              .textTheme
              .bodyText2!
              .copyWith(color: AppColors.black60),
        ),
      ]);
}
