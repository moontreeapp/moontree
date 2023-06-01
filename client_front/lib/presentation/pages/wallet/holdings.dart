// ignore_for_file: avoid_print
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:shimmer/shimmer.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/theme/fonts.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

class WalletHoldings extends StatelessWidget {
  const WalletHoldings({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('WalletHoldings');

  /// TODO: modify cubit instead of setstate
// ignore: unused_element

  //GestureDetector(
  //  onTap: () {
  //    sail.to(
  //      '/wallet/holding',
  //      arguments: {'chainSymbol': 'WhaleStreet'},
  //    );
  //  },
  //  child: const ListTile(
  //    leading: CircleAvatar(
  //      backgroundColor: AppColors.primary,
  //      child: Text('W'),
  //    ),
  //    title: Text('WhaleStreet'),
  //  ),
  //),
  Future<void> refresh(WalletHoldingsViewCubit cubit) async {
    //cubit.update(isSubmitting: true);
    await cubit.setHoldingViews(force: true);
  }

  @override
  Widget build(BuildContext context) {
    if (components.cubits.tutorial.missing.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (components.cubits.location.state.path == '/wallet/holdings') {
          components.cubits.tutorial.load();
        }
      });
    }
    final WalletHoldingsViewCubit cubit = components.cubits.holdingsView;
    if (cubit.state.ranWallet != Current.wallet ||
        cubit.state.ranChainNet != pros.settings.chainNet) {
      cubit.update(isSubmitting: true);
    }
    cubit.setHoldingViews();
    return GestureDetector(
        onTap: () => refresh(cubit), //FocusScope.of(context).unfocus(),
        child: flutter_bloc.BlocBuilder<WalletHoldingsViewCubit,
                WalletHoldingsViewState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, WalletHoldingsViewState state) {
              if (state.isSubmitting == true) {
                return RefreshIndicator(
                    onRefresh: () => refresh(cubit),
                    child: components.empty.getAssetsPlaceholder(context,
                        scrollController: ScrollController(),
                        count: 1,
                        holding: true));
              } else {
                if (state.holdingsViews.length == 1 &&
                    state.holdingsViews.first.sats == 0) {
                  // notice in new design used but empty wallet gets lumped in here too
                  if (pros.wallets.length == 1) {
                    return RefreshIndicator(
                        onRefresh: () => refresh(cubit),
                        child: ComingSoonPlaceholder(
                            scrollController: ScrollController(),
                            header: 'Get Started',
                            message:
                                'Use the Import feature in the menu or Receive button below to add ${pros.settings.chain.title} & assets to your wallet.'));
                  } else {
                    return RefreshIndicator(
                        onRefresh: () => refresh(cubit),
                        child: ComingSoonPlaceholder(
                            scrollController: ScrollController(),
                            header: 'Empty Wallet',
                            message:
                                'This wallet has never been used before.\nClick "Receive" to get started.'));
                  }
                } else {
                  //if (state.holdingsViews.isNotEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => refresh(cubit),
                    child: HoldingsView(cubit: cubit),
                  );
                }
              }
            }));
  }
}

class HoldingsView extends StatefulWidget {
  final WalletHoldingsViewCubit cubit;
  const HoldingsView({required this.cubit, super.key});

  @override
  State<HoldingsView> createState() => _HoldingsView();
}

class _HoldingsView extends State<HoldingsView> {
  ScrollController scrollController = ScrollController();
  final Security currentCrypto = pros.securities.currentCoin;
  final Wallet wallet = Current.wallet;
  List<AssetHolding> _hiddenAssets = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  Future<void> refresh(WalletHoldingsViewCubit cubit) async =>
      await cubit.setHoldingViews(force: true);

  void _toggleUSD() {
    if (pros.rates.primaryIndex
            .getOne(pros.securities.RVN, pros.securities.USD) ==
        null) {
      widget.cubit.update(showUSD: false);
    } else {
      widget.cubit.update(showUSD: !widget.cubit.state.showUSD);
    }
  }

  void _togglePath() {
    widget.cubit.update(showPath: !widget.cubit.state.showPath);
  }

  Future<void> _hideAsset(AssetHolding holding, Security security) async {
    await pros.settings.addAllHiddenAssets([security]);
    _hiddenAssets.add(holding);
    // show that it's hidden
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return flutter_bloc.BlocBuilder<SearchCubit, SearchCubitState>(
        builder: (BuildContext context, SearchCubitState state) {
      final List<Widget> rvnHolding = <Widget>[];
      final List<Widget> assetHoldings = <Widget>[];
      for (final AssetHolding holding in widget.cubit.state.assetHoldings
          .where((e) => !pros.settings.hiddenAssets.contains(
                e.security,
              ))) {
        final Widget thisHolding = Visibility(
            visible: !_hiddenAssets.contains(holding),
            child: ListTile(
              //dense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
              onTap: () async => onTap(widget.cubit.state.ranWallet, holding),
              onLongPress: () {
                if (!holding.symbolSymbol.isCoin) {
                  _hideAsset(holding, holding.security);
                  streams.app.behavior.snack.add(Snack(
                    positive: true,
                    message: 'Asset has been hidden',
                    delay: 0,
                  ));
                }
              },
              leading: leadingIcon(holding),
              title: title(holding, currentCrypto),
            ));
        if (holding.symbol == currentCrypto.symbol) {
          //if (pros.securities.coinSymbols.contains(holding.symbol)) {
          rvnHolding.add(thisHolding);
          rvnHolding.add(const Divider(
            height: 1,
            indent: 70,
            endIndent: 0,
          ));
        } else {
          if (state.text == '' || holding.symbol.contains(state.text)) {
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
          padding: EdgeInsets.zero,
          controller: scrollController,
          physics: const ClampingScrollPhysics(),
          children: <Widget>[
            ...rvnHolding,
            ...assetHoldings,
            ...<Widget>[components.empty.blankNavArea(context)]
          ]);
      //if (services.developer.advancedDeveloperMode == true) {
      //  return RefreshIndicator(
      //    onRefresh: () async {
      //      streams.app.behavior.snack.add(Snack(message: 'Resyncing...'));
      //      await services.client.resetMemoryAndConnection();
      //      setState(() {});
      //    },
      //    child: listView,
      //  );
      //}
      return GestureDetector(
        onTap: () async {
          refresh(widget.cubit);
        },
        child: listView,
      );
    });
  }

  void navigate(BalanceView balance, {Wallet? wallet}) {
    streams.app.wallet.asset.add(balance.symbol); // todo: remove
    sail.to('/wallet/holding', symbol: balance.symbol
        //arguments: <String, Object?>{'holding': balance, 'walletId': wallet?.id},
        );
  }

  Future<void> onTap(Wallet? wallet, AssetHolding holding) async {
    if (holding.length == 1) {
      navigate(holding.balance!, wallet: wallet);
    } else {
      components.cubits.bottomModalSheet.show(
          children: assetOptions(
        context: context,
        onTap: () {
          components.cubits.bottomModalSheet.hide();
        },
        symbol: holding.symbol,
        names: <String>[
          if (holding.main != null) 'main',
          if (holding.sub != null) 'sub',
          if (holding.subAdmin != null) 'sub admin',
          if (holding.admin != null) 'admin',
          if (holding.restricted != null) 'restricted',
          if (holding.restrictedAdmin != null) 'restricted admin',
          if (holding.qualifier != null) 'qualifier',
          if (holding.qualifierSub != null) 'sub qualifier',
          if (holding.nft != null) 'nft',
          if (holding.channel != null) 'channel',
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
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.sub != null)
            services.conversion.securityAsReadable(
              holding.sub!.sats,
              security: Security(
                symbol: holding.sub!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.subAdmin != null)
            services.conversion.securityAsReadable(
              holding.subAdmin!.sats,
              security: Security(
                symbol: holding.subAdmin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.admin != null)
            services.conversion.securityAsReadable(
              holding.admin!.sats,
              security: Security(
                symbol: holding.admin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.restricted != null)
            services.conversion.securityAsReadable(
              holding.restricted!.sats,
              security: Security(
                symbol: holding.restricted!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.restrictedAdmin != null)
            services.conversion.securityAsReadable(
              holding.restrictedAdmin!.sats,
              security: Security(
                symbol: holding.restrictedAdmin!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.qualifier != null)
            services.conversion.securityAsReadable(
              holding.qualifier!.sats,
              security: Security(
                symbol: holding.qualifier!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.qualifierSub != null)
            services.conversion.securityAsReadable(
              holding.qualifierSub!.sats,
              security: Security(
                symbol: holding.qualifierSub!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.nft != null)
            services.conversion.securityAsReadable(
              holding.nft!.sats,
              security: Security(
                symbol: holding.nft!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
          if (holding.channel != null)
            services.conversion.securityAsReadable(
              holding.channel!.sats,
              security: Security(
                symbol: holding.channel!.symbol,
                chain: pros.settings.chain,
                net: pros.settings.net,
              ),
              asUSD: widget.cubit.state.showUSD,
            ),
        ],
      ));
    }
  }

  Widget leadingIcon(AssetHolding holding) => SizedBox(
          height: 40,
          width: 40,
          child: //Hero(
              //tag: holding.symbol.toLowerCase(),
              //child:
              components.icons.assetAvatar(
                  //holding.admin != null
                  //    ? holding.adminSymbol!
                  //    : holding.restricted != null
                  //        ? holding.restrictedSymbol!
                  //        : holding.qualifier != null
                  //            ? holding.qualifierSymbol!
                  //            : holding.channel != null
                  //                ? holding.channelSymbol!
                  //                : holding.nft != null
                  //                    ? holding.nftSymbol!
                  //                    : holding.subAdmin != null
                  //                        ? holding.subAdminSymbol!
                  //                        : holding.sub != null
                  //                            ? holding.subSymbol!
                  //                            : holding.qualifierSub != null
                  //                                ? holding.qualifierSubSymbol!
                  //                                : holding.symbol,
                  holding.symbol,
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
                        : services.developer.developerMode &&
                                widget.cubit.state.showPath
                            ? holding.symbol
                            : holding.last,
                    style: Theme.of(context).textTheme.bodyLarge),
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
                      asUSD: widget.cubit.state.showUSD),
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: AppColors.black60),
        ),
      ]);
}

List<Widget> assetOptions({
  BuildContext? context,
  Function? onTap,
  Function(ChainNet)? first,
  Function? second,
  required String symbol,
  required Iterable<String> names,
  required Iterable<void Function()> behaviors,
  required Iterable<String> values,
}) =>
    <Widget>[
      for (List x
          in zipIterable([names.toList(), behaviors.toList(), values.toList()]))
        ListTile(
          onTap: () {
            if (onTap != null) {
              onTap();
            }
            (x[1] as void Function())(); // behavior
          },
          leading: components.icons.assetAvatar(
              {
                'main': symbol,
                'sub': symbol,
                'sub admin': symbol,
                'admin': '$symbol!',
                'restricted': '\$$symbol',
                'restricted admin': '\$$symbol',
                'qualifier': '#$symbol',
                'sub qualifier': '#$symbol',
                'nft': symbol,
                'channel': symbol,
              }[(x[0] as String)]!,
              size: 24),
          title: Text((x[0] as String).toTitleCase(),
              style: Theme.of(context ?? components.routes.context!)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: AppColors.black87)),
          trailing: Text((x[2] as String),
              style: Theme.of(context!).textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeights.bold,
                  letterSpacing: 0.1,
                  color: AppColors.black60)),
        ),
    ];
