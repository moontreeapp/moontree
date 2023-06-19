// ignore_for_file: avoid_print

import 'dart:async';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/theme/fonts.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

class ManageHoldings extends StatelessWidget {
  const ManageHoldings({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('ManageHoldings');

  Future<void> refresh(ManageHoldingsViewCubit cubit) async {
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
    final ManageHoldingsViewCubit cubit = components.cubits.manageHoldingsView;
    if (cubit.state.ranWallet != Current.wallet ||
        cubit.state.ranChainNet != pros.settings.chainNet) {
      cubit.update(isSubmitting: true);
    }
    cubit.setHoldingViews();
    return GestureDetector(
        onTap: () => refresh(cubit), //FocusScope.of(context).unfocus(),
        child: flutter_bloc.BlocBuilder<ManageHoldingsViewCubit,
                ManageHoldingsViewState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, ManageHoldingsViewState state) {
              if (state.isSubmitting == true) {
                return RefreshIndicator(
                    onRefresh: () => refresh(cubit),
                    child: components.empty.getAssetsPlaceholder(context,
                        scrollController: ScrollController(),
                        count: 1,
                        holding: true));
              } else {
                if (state.holdingsViews.length == 0) {
                  return RefreshIndicator(
                      onRefresh: () => refresh(cubit),
                      child: ComingSoonPlaceholder(
                          scrollController: ScrollController(),
                          header: 'Get Started',
                          message:
                              'Use the Create button to make an asset you can manage.'));
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
  final ManageHoldingsViewCubit cubit;
  const HoldingsView({required this.cubit, super.key});

  @override
  State<HoldingsView> createState() => _HoldingsView();
}

class _HoldingsView extends State<HoldingsView> {
  TextEditingController searchController = TextEditingController();
  ScrollController scrollController = ScrollController();
  final Security currentCrypto = pros.securities.currentCoin;
  final Wallet wallet = Current.wallet;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> refresh(ManageHoldingsViewCubit cubit) async =>
      await cubit.setHoldingViews(force: true);

  void _togglePath() {
    widget.cubit.update(showPath: !widget.cubit.state.showPath);
  }

  @override
  Widget build(BuildContext context) {
    return flutter_bloc.BlocBuilder<LocationCubit, LocationCubitState>(builder:
        (BuildContext locationContext, LocationCubitState locationState) {
      final List<Widget> assetHoldings = <Widget>[];
      for (final AssetHolding holding in widget.cubit.state.assetHoldings) {
        final ListTile thisHolding = ListTile(
          //dense: true,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          onTap: () async {
            if (components.cubits.location.menuOpened) {
              sail.menu(open: false);
            } else {
              onTap(widget.cubit.state.ranWallet, holding);
            }
          },
          onLongPress: _togglePath,
          leading: leadingIcon(holding),
          title: title(holding, currentCrypto),
        );
        if (searchController.text == '' ||
            holding.symbol.contains(searchController.text.toUpperCase())) {
          assetHoldings.add(thisHolding);
          assetHoldings.add(const Divider(height: 1));
        }
      }

      final ListView listView = ListView(
          padding: EdgeInsets.zero,
          controller: scrollController,
          physics: locationState.menuOpen
              ? const NeverScrollableScrollPhysics()
              : const ClampingScrollPhysics(),
          children: <Widget>[
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

      // this seems to make the animations jumpy...
      if (locationState.menuOpen) {
        if (mounted) {
          scrollController.jumpTo(0);
        }
      }

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
    sail.to('/manage/holding', symbol: balance.symbol
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
                        : pros.settings.fullAssetsShown
                            ? holding.symbol
                            : holding.last,
                    //: services.developer.developerMode &&
                    //        widget.cubit.state.showPath
                    //    ? holding.symbol
                    //    : holding.last,
                    style: Theme.of(context).textTheme.bodyLarge),
              )),
        ]),

        /// this could be the total amount in circulation if we grab that in the
        /// cubit, but right now we don't.
        //Text(
        //  holding.mainLength > 1 && holding.restricted != null
        //      ? <String>[
        //          if (holding.main != null) 'Main',
        //          if (holding.admin != null) 'Admin',
        //          if (holding.restricted != null) 'Restricted',
        //          if (holding.restrictedAdmin != null) 'Restricted Admin',
        //        ].join(', ')
        //      : services.conversion
        //          .securityAsReadable(holding.balance?.sats ?? 0,
        //              security: holding.balance == null
        //                  ? const Security(
        //                      symbol: 'unknown',
        //                      chain: Chain.none,
        //                      net: Net.test,
        //                    )
        //                  : Security(
        //                      symbol: holding.balance!.symbol,
        //                      chain: pros.settings.chain,
        //                      net: pros.settings.net,
        //                    ),
        //              asUSD: widget.cubit.state.showUSD),
        //  style: Theme.of(context)
        //      .textTheme
        //      .bodyMedium!
        //      .copyWith(color: AppColors.black60),
        //),
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
            trailing: //(x[2] as String) != null
                //?
                Text((x[2] as String),
                    style: Theme.of(context!).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeights.bold,
                        letterSpacing: 0.1,
                        color: AppColors.black60))
            //: null,
            ),
    ];
