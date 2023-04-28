import 'package:client_front/application/utilities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/wallet_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/asset_metadata_class.dart';
import 'package:client_back/server/src/protocol/protocol.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/application/extra/cubit.dart';
import 'package:client_front/application/front/cubit.dart';
import 'package:client_front/application/transactions/cubit.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/back/coinspec/tabs.dart';
import 'package:client_front/presentation/widgets/front/lists/transactions.dart';
import 'package:client_front/presentation/services/services.dart' as services;
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/presentation/components/components.dart'
    as components;

class WalletHolding extends StatelessWidget {
  const WalletHolding({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('Holding');

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FrontContainerCubit, FrontContainerCubitState>(
          builder: (BuildContext context, FrontContainerCubitState state) =>
              //state.mempoolViews.length + state.transactionViews.length > 0
              state.containerHeight == null
                  ? SizedBox.shrink()
                  : components.empty.getTransactionsPlaceholder(
                      context,
                      scrollController: ScrollController(),
                      count: 1,
                    ));
}

class FrontHoldingExtra extends StatefulWidget {
  const FrontHoldingExtra({Key? key}) : super(key: key);

  @override
  FrontHoldingExtraState createState() => FrontHoldingExtraState();
}

class FrontHoldingExtraState extends State<FrontHoldingExtra>
    with TickerProviderStateMixin {
  final DraggableScrollableController draggableScrollableController =
      DraggableScrollableController();

  final double minSize =
      services.screen.frontContainer.midHeightPercentage * 1 +
          (48 / services.screen.frontContainer.maxHeight);
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late FrontContainerCubit heightCubit;
  double draggableHeight =
      services.screen.frontContainer.midHeightPercentage * 1 +
          (48 / services.screen.frontContainer.maxHeight);
  int lengthOfLoadMore = 0;
  double currentMaxScroll = 0;
  double previousMaxScroll = 0;
  bool timedCalling = false;

  @override
  void initState() {
    super.initState();
    heightCubit = BlocProvider.of<FrontContainerCubit>(context);
    Future.delayed(animation.fadeDuration).then((_) {
      if (components.cubits.location.state.path == '/wallet/holding') {
        heightCubit.setHidden(true);
      }
    });
    draggableScrollableController.addListener(scrollListener);
    _controller = AnimationController(
      vsync: this,
      duration: animation.fadeDuration,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    draggableScrollableController.removeListener(scrollListener);
    draggableScrollableController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void scrollListener() => heightCubit.setHeightToExactly(
      height: (services.screen.frontContainer.maxHeight - 40) *
          draggableScrollableController.size);

  @override
  Widget build(BuildContext context) {
    final TransactionsViewCubit cubit =
        BlocProvider.of<TransactionsViewCubit>(context);
    // first set the wallet and security so we can set the coinspec
    cubit.set(
        wallet: pros.wallets.currentWallet,
        security: Security(
          symbol: components.cubits.location.state.symbol ??
              cubit.state.security.symbol,
          chain: pros.settings.chain,
          net: pros.settings.net,
        ));
    // then get the transactions from the future endpoint call
    if (!pros.wallets.currentWallet.minerMode) {
      cubit.setInitial();
    }
    return BlocBuilder<TransactionsViewCubit, TransactionsViewState>(
        bloc: cubit..enter(),
        builder: (BuildContext context, TransactionsViewState state) =>
            Container(
                color: Colors.transparent,
                height: services.screen.frontContainer.maxHeight,
                width: services.screen.width,
                child: DraggableScrollableSheet(
                    initialChildSize: minSize,
                    minChildSize: minSize,
                    maxChildSize: (state.mempoolViews.length +
                                        state.transactionViews.length) *
                                    52 +
                                (40 + 16 + 16 + 16) >
                            services.screen.frontContainer.maxHeight / 2
                        ? 1
                        : minSize,
                    controller: draggableScrollableController,
                    builder: (BuildContext context,
                        ScrollController scrollController) {
                      _scrollListener() {
                        try {
                          state.scrollObserver
                              .add(draggableScrollableController.size);
                        } catch (e) {
                          return;
                        }
                      }

                      scrollController.addListener(() async {
                        /// just call this as soon as we start scrolling
                        /// actually thats not efficient for the server
                        double maxScroll =
                            scrollController.position.maxScrollExtent;
                        if (currentMaxScroll < maxScroll) {
                          previousMaxScroll = currentMaxScroll;
                          currentMaxScroll = maxScroll;
                        }
                        double currentScroll = scrollController.position.pixels;
                        if (currentScroll > previousMaxScroll) {
                          if (lengthOfLoadMore <
                              state.transactionViews.length) {
                            lengthOfLoadMore = state.transactionViews.length;
                            await cubit.addSetTransactionViews();
                          }
                        }
                        if (currentScroll == maxScroll) {
                          // first time we hit the bottom, set a timer
                          if (!timedCalling) {
                            timedCalling = true;
                            await Future.delayed(
                              Duration(seconds: 5),
                              () async {
                                // if max hasn't changed after 5 seconds
                                if (mounted &&
                                    maxScroll ==
                                        scrollController
                                            .position.maxScrollExtent) {
                                  // call it again
                                  await cubit.addSetTransactionViews(
                                      force: true);
                                }
                              },
                            ).then((value) => timedCalling = false);
                          }

                          //if (lengthOfLoadMore <
                          //    state.transactionViews.length) {
                          //  print('length');
                          //  lengthOfLoadMore =
                          //      state.transactionViews.length;
                          //  await cubit.addSetTransactionViews();
                          //}
                        }
                      });
                      draggableScrollableController
                          .addListener(_scrollListener);

                      // 2 options: a. move the metadatatabs to the back, and
                      // don't have them move with the scroll, or b. don't put the
                      // front curve here and ignore the jump that the front curve
                      // makes when going back to the home page or solve for it.
                      return //FrontCurve(
                          //color: Colors.transparent,
                          //fuzzyTop: true,
                          //child:
                          BlocBuilder<ExtraContainerCubit, ExtraContainerState>(
                              //bloc: cubit..enter(),
                              builder: (BuildContext context,
                                      ExtraContainerState state) =>
                                  AnimatedContainer(
                                      duration: animation.fadeDuration,
                                      curve: Curves.easeInOut,
                                      alignment: Alignment.center,
                                      child: FadeTransition(
                                          opacity: _opacityAnimation,
                                          child: CoinDetailsGlidingSheet(
                                            cubit: cubit,
                                            cachedMetadataView: cubit
                                                    .nullCacheView
                                                ? null
                                                : MetadataView(cubit: cubit),
                                            dController:
                                                draggableScrollableController,
                                            scrollController: scrollController,
                                          )
                                          /*ListView.builder(
                                            controller: scrollController,
                                            itemCount: 100,
                                            itemBuilder: (BuildContext context,
                                                    int index) =>
                                                ListTile(
                                                    title: Text(
                                                        'Item $index')))*/
                                          )))
                          //)
                          ;
                    })));
  }
}

class CoinDetailsGlidingSheet extends StatefulWidget {
  const CoinDetailsGlidingSheet({
    this.cachedMetadataView,
    required this.cubit,
    required this.dController,
    required this.scrollController,
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
  final Widget? cachedMetadataView;
  final DraggableScrollableController dController;
  final ScrollController scrollController;

  @override
  State<CoinDetailsGlidingSheet> createState() =>
      _CoinDetailsGlidingSheetState();
}

class _CoinDetailsGlidingSheetState extends State<CoinDetailsGlidingSheet> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.cubit.reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        //if (widget.cachedMetadataView != null) // always show the tabs, but maybe grey out data if it's not populated
        CoinSpecTabs(cubit: widget.cubit),
        Padding(
            padding: EdgeInsets.only(
                top: /*widget.cachedMetadataView != null ?*/ 48 /*: 0*/),
            child: FrontCurve(
              color: Colors.white,
              frontLayerBoxShadow: shadows.none,
              child: TransactionsContent(
                widget.cubit,
                widget.cachedMetadataView,
                widget.scrollController,
              ),
            ))
      ],
    );
  }
}

class MetaDataWidget extends StatelessWidget {
  const MetaDataWidget(this.cacheView, {Key? key}) : super(key: key);
  final Widget? cacheView;

  @override
  Widget build(BuildContext context) {
    return cacheView ??
        components.empty.message(
          context,
          icon: Icons.description,
          msg: '\nNo metadata.\n',
        );
  }
}

class MetadataView extends StatelessWidget {
  final TransactionsViewCubit cubit;
  const MetadataView({Key? key, required this.cubit}) : super(key: key);

  Future<void> refresh() async {
    //setState(() {
    cubit.setMetadataView(force: true);
    //});
  }

  @override
  Widget build(BuildContext context) {
    //final Asset securityAsset = cubit.state.security.asset!;
    final AssetMetadata? securityAsset = cubit.state.metadataView;

    List<Widget> children = <Widget>[];
    //if (securityAsset.primaryMetadata == null &&
    //    securityAsset.hasData &&
    //    securityAsset.data!.isIpfs) {
    if (securityAsset != null) {
      if (securityAsset.associatedData != null) {
        if (securityAsset.associatedData!.toHex().isIpfs) {
          return Container(
            alignment: Alignment.topCenter,
            height:
                (cubit.state.scrollObserver.value.ofMediaHeight(context) + 32) /
                    2,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: components.buttons.actionButtonSoft(
                context,
                label: 'View Data',
                onPressed: () => components.message.giveChoices(
                  context,
                  title: 'View Data',
                  content: 'View data in external browser?',
                  behaviors: <String, void Function()>{
                    'CANCEL': Navigator.of(context).pop,
                    'BROWSER': () {
                      Navigator.of(context).pop();
                      launchUrl(Uri.parse(
                          'https://ipfs.io/ipfs/${securityAsset.associatedData!.toHex()}'));
                    },
                  },
                ),
              ),
            ),
          );
        } else {
          // not ipfs - show whatever it is. todo: handle image etc here.
          children = <Widget>[
            SelectableText(securityAsset.associatedData!.toHex())
          ];
        }
      } else {
        // no associated data - show details
        children = <Widget>[
          ListTile(
            title: Text(
              cubit.state.security.isCoin
                  ? 'Cirulcating Supply:'
                  : 'Total Supply:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              securityAsset.totalSupply.asCoin.toSatsCommaString(),
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Divisibility:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.divisibility}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Reissuable:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.reissuable ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
          ListTile(
            title: Text(
              'Frozen:',
              style: Theme.of(context).textTheme.bodyText1,
            ),
            trailing: SelectableText(
              '${securityAsset.frozen ? 'yes' : 'no'}',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ),
        ];
      }
    } else {
      // asset metadata not found
    }
    //} else if (securityAsset.primaryMetadata == null) {
    //children = <Widget>[SelectableText(securityAsset.metadata)];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.imagePath) {
    //  children = <Widget>[
    //    Image.file(AssetLogos()
    //        .readImageFileNow(securityAsset.primaryMetadata!.data ?? ''))
    //  ];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.jsonString) {
    //  children = <Widget>[
    //    SelectableText(securityAsset.primaryMetadata!.data ?? '')
    //  ];
    //} else if (securityAsset.primaryMetadata!.kind == MetadataType.unknown) {
    //  children = <Widget>[
    //    SelectableText(securityAsset.primaryMetadata!.metadata),
    //    SelectableText(securityAsset.primaryMetadata!.data ?? '')
    //  ];
    //}
    return RefreshIndicator(
        onRefresh: () => refresh(),
        child:
            ListView(padding: const EdgeInsets.all(10.0), children: children));
  }
}

class TransactionsContent extends StatelessWidget {
  const TransactionsContent(
    this.cubit,
    this.cachedMetadataView,
    this.scrollController, {
    Key? key,
  }) : super(key: key);
  final TransactionsViewCubit cubit;
  final Widget? cachedMetadataView;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
        stream: cubit.state.currentTab,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          final String tab = snapshot.data ?? 'HISTORY';
          final bool showTransactions = tab == CoinSpecTabs.tabIndex[0];
          return showTransactions
              ? TransactionList(
                  cubit: cubit,
                  scrollController: scrollController,
                  symbol: cubit.state.security.symbol,
                  mempool: cubit.state.mempoolViews,
                  transactions: cubit.state.transactionViews,
                  msg: '\nNo ${cubit.state.security.symbol} transactions.\n')
              : MetaDataWidget(cachedMetadataView);
        });
  }
}

double getOpacityFromController(
  double controllerValue,
  double minHeightFactor,
) {
  double opacity = 1;
  if (controllerValue >= 0.9) {
    opacity = 0;
  } else if (controllerValue <= minHeightFactor) {
    opacity = 1;
  } else {
    opacity = (0.9 - controllerValue) * 5;
  }
  if (opacity > 1) {
    return 1;
  }
  if (opacity < 0) {
    return 0;
  }
  return opacity;
}
