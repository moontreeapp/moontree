import 'package:tuple/tuple.dart';
import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/domain/utils/alphacon.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/presentation/services/services.dart'
    show sail, screen;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:wallet_utils/wallet_utils.dart';

TextStyle style(BuildContext context, Snack? snack) => snack?.positive ?? true
    ? Theme.of(context).textTheme.bodyMedium!.copyWith(color: AppColors.white)
    : Theme.of(context)
        .textTheme
        .bodyMedium!
        .copyWith(color: AppColors.errorlight);

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController snackbarController;
  static const double snackbarHeight = 40;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: animation.slideDuration,
    );
    snackbarController = AnimationController(
      vsync: this,
      duration: animation.slideDuration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    snackbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NavbarCubit, NavbarCubitState>(
          builder: (BuildContext context, NavbarCubitState state) {
        if ((state.previousNavbarHeight == NavbarHeight.max &&
                state.currentNavbarHeight == NavbarHeight.mid) ||
            (state.previousNavbarHeight != NavbarHeight.hidden &&
                state.currentNavbarHeight == NavbarHeight.hidden)) {
          animationController.value = 0.0;
          animationController.forward();
        } else if (state.previousNavbarHeight == NavbarHeight.hidden &&
            state.currentNavbarHeight == NavbarHeight.hidden) {
          animationController.value = 1.0;
        } else if (state.currentNavbarHeight == NavbarHeight.max) {
          animationController.value = 1.0;
          animationController.reverse();
        } else if (state.previousNavbarHeight == NavbarHeight.hidden &&
            state.currentNavbarHeight == NavbarHeight.mid) {
          animationController.value = 1.0;
          animationController.reverse();
        }

        final maxHeight = (state.showSections
                ? screen.navbar.maxHeight
                : screen.navbar.midHeight) +
            snackbarHeight;
        return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) {
              double slide;
              //if (state.currentNavbarHeight == NavbarHeight.hidden &&
              //    state.previousNavbarHeight == NavbarHeight.mid) {
              //  slide =
              //      ((maxHeight - screen.navbar.midHeight) - snackbarHeight) *
              //          animationController.value;
              //} else
              if (state.currentNavbarHeight == NavbarHeight.hidden &&
                  state.previousNavbarHeight == NavbarHeight.mid) {
                slide =
                    ((maxHeight - snackbarHeight) - screen.navbar.midHeight) *
                        animationController.value;
                slide += screen.navbar.midHeight;
              } else if (state.currentNavbarHeight == NavbarHeight.hidden) {
                slide =
                    (maxHeight - snackbarHeight) * animationController.value;
              } else if (state.currentNavbarHeight == NavbarHeight.mid &&
                  state.previousNavbarHeight == NavbarHeight.hidden) {
                slide =
                    ((maxHeight - screen.navbar.midHeight) - snackbarHeight) *
                        animationController.value;
                //print('state.currentNavbarHeight ${state.currentNavbarHeight}');
                //print(
                //    'state.previousNavbarHeight ${state.previousNavbarHeight}');
                slide +=
                    ((maxHeight - screen.navbar.midHeight) - snackbarHeight);
              } else if (state.currentNavbarHeight == NavbarHeight.mid) {
                slide =
                    ((maxHeight - screen.navbar.midHeight) - snackbarHeight) *
                        animationController.value;
              } else if (state.currentNavbarHeight == NavbarHeight.max &&
                  state.previousNavbarHeight == NavbarHeight.hidden) {
                slide =
                    (maxHeight - snackbarHeight) * animationController.value;
              } else if (state.currentNavbarHeight == NavbarHeight.max &&
                  state.previousNavbarHeight == NavbarHeight.mid) {
                slide =
                    ((maxHeight - screen.navbar.midHeight) - snackbarHeight) *
                        animationController.value;
              } else {
                slide = (screen.navbar.midHeight / maxHeight) *
                    animationController.value;
              }
              return Transform(
                  alignment: Alignment.bottomCenter,
                  transform: Matrix4.identity()..translate(0.0, slide, 0.0),
                  child: Container(
                      width: screen.width,
                      height: maxHeight,
                      child:
                          Stack(alignment: Alignment.bottomCenter, children: [
                        BlocBuilder<SnackbarCubit, SnackbarCubitState>(builder:
                            (BuildContext snackbarContext,
                                SnackbarCubitState snackbarState) {
                          return AnimatedBuilder(
                              animation: snackbarController,
                              builder: (BuildContext context, Widget? child) {
                                double snackbarSlide;
                                //Widget snackContents;
                                if (snackbarState.snack != null) {
                                  snackbarController.reverse();
                                  snackbarSlide =
                                      maxHeight * snackbarController.value;
                                  //snackContents = Text(
                                  //  'snack',
                                  //  textAlign: TextAlign.right,
                                  //  maxLines: 1,
                                  //  overflow: TextOverflow.ellipsis,
                                  //  style: style(
                                  //      snackbarContext,
                                  //      snackbarState.snack ??
                                  //          snackbarState.prior),
                                  //);
                                } else if (snackbarState.prior != null) {
                                  snackbarController.forward();
                                  snackbarSlide =
                                      maxHeight * snackbarController.value;
                                } else {
                                  snackbarSlide = maxHeight;
                                }
                                final snack =
                                    snackbarState.snack ?? snackbarState.prior;
                                return Transform(
                                    alignment: Alignment.bottomCenter,
                                    transform: Matrix4.identity()
                                      ..translate(0.0, snackbarSlide, 0.0),
                                    child: GestureDetector(
                                        onTap: () {
                                          if (snack?.copy != null) {
                                            Clipboard.setData(ClipboardData(
                                                text: snack!.copy!));
                                          }
                                          components.cubits.snackbar.clear();
                                        },
                                        behavior: HitTestBehavior.opaque,
                                        child: Container(
                                            width: screen.width,
                                            height: maxHeight,
                                            clipBehavior: Clip.antiAlias,
                                            padding: const EdgeInsets.only(
                                                top: 8, left: 16, right: 16),
                                            decoration: const BoxDecoration(
                                              color: Colors.black,
                                              borderRadius:
                                                  shapes.topRoundedBorder16,
                                              //boxShadow: shadows.snackbar, // looks weird with a shadow actually.
                                            ),
                                            child:
                                                SnackContents(snack: snack))));
                              });
                        }),
                        Container(
                            width: screen.width,
                            height: maxHeight - snackbarHeight,
                            clipBehavior: Clip.antiAlias,
                            padding: const EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: shapes.topRoundedBorder16,
                              boxShadow: shadows.navbar,
                            ),
                            child: Column(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                // we will need to make these buttons dependant upon the navigation
                                // of the front page through streams but for now, we'll show they
                                // can changed based upon whats selected:
                                NavbarActions(),
                                if (state.showSections) ...<Widget>[
                                  const SizedBox(height: 16),
                                  Padding(
                                      padding: EdgeInsets.zero,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: <Widget>[
                                          SectionIcon(section: Section.wallet),
                                          SectionIcon(
                                              section: Section.scan,
                                              preNavHook: () {
                                                sail.to('/wallet/holdings',
                                                    section: Section.wallet);
                                              }),
                                          SectionIcon(section: Section.manage),
                                        ],
                                      ))
                                ]
                              ],
                            )
                            /* 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            // children: [Text('Column 1')],
                            children: [
                              Container(
                                alignment: Alignment.center,
                                // decoration: BoxDecoration(color: AppColors.primary),
                                height: maxHeight / 2,
                                width: MediaQuery.of(context).size.width / 2,
                                child: ElevatedButton(
                                    onPressed: () {},
                                    child: const Text('Send')),
                              )
                            ],
                          ),
                          Column(
                            children: [
                              Column(
                                // children: [Text('Column 1')],
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: AppColors.primary),
                                    height:
                                        maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 2,
                                    child: ElevatedButton(
                                        onPressed: () {},
                                        child: const Text('Receive')),
                                  )
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              GestureDetector(
                                  onTap: () async => await sail.sailTo(
                                      section: Section.wallet),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.money),
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                  onTap: () async => await sail.sailTo(
                                      section: Section.manage),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.add),
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                  onTap: () async => await sail.sailTo(
                                      section: Section.swap),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.swap_horiz),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),*/
                            ),
                      ])));
            });
      });
}

class SectionIcon extends StatefulWidget {
  final Section section;
  final Function? preNavHook;
  const SectionIcon({super.key, required this.section, this.preNavHook});

  @override
  _SectionIconState createState() => _SectionIconState();
}

class _SectionIconState extends State<SectionIcon> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<LocationCubit,
          LocationCubitState>(
      builder: (BuildContext context, LocationCubitState state) =>
          GestureDetector(
              onTap: () {
                if (widget.preNavHook != null) {
                  widget.preNavHook!();
                }
                sail.to(null, section: widget.section);
              },
              child: SvgPicture.asset(
                  'assets/icons/custom/mobile/${widget.section.name}'
                  '${state.section == widget.section ? '-active' : ''}.svg')));
}

class NavbarActions extends StatelessWidget {
  const NavbarActions({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BlocBuilder<LocationCubit,
          LocationCubitState>(
      builder: (BuildContext context, LocationCubitState locationState) =>
          BlocBuilder<ConnectionStatusCubit, ConnectionStatusCubitState>(
              builder: (BuildContext context,
                      ConnectionStatusCubitState connectionState) =>
                  //BlocBuilder<WalletHoldingsViewCubit, WalletHoldingsViewState>(
                  //    builder: (BuildContext context,
                  //            WalletHoldingsViewState holdingState) =>
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: ((locationState.section == Section.wallet
                            ? <Widget>[
                                /// never show import for this button
                                //if (components.cubits.holdingsView.state
                                //            .holdingsViews.length ==
                                //        1 &&
                                //    components.cubits.holdingsView.state
                                //            .holdingsViews.first.sats ==
                                //        0)
                                //  Expanded(
                                //      child: BottomButton(
                                //    label: 'import',
                                //    enabled: true,
                                //    onPressed: () =>
                                //        sail.to('/restore/import'),
                                //  ))
                                //else
                                Expanded(
                                    child: BottomButton(
                                  label: 'send',
                                  enabled: connectionState.isConnected,
                                  disabledOnPressed: () {
                                    if (!connectionState.isConnected) {
                                      streams.app.behavior.snack.add(Snack(
                                          message: 'Not connected to network'));
                                    }
                                  },
                                  onPressed: () async {
                                    if (_ableToSend(action: 'send')) {
                                      //await components.cubits.simpleSendForm
                                      //    .setSecurity(components.cubits
                                      //        .transactionsView.state.security);
                                      sail.to('/wallet/send', arguments: {
                                        'security': components.cubits
                                            .transactionsView.state.security
                                      });
                                    }
                                  },
                                )),
                                Expanded(
                                    child: BottomButton(
                                  label: 'receive',
                                  onPressed: () => sail.to('/receive'),
                                ))
                              ]
                            : locationState.section == Section.manage
                                ? <Widget>[
                                    if (locationState.path ==
                                        '/manage/holdings')
                                      Expanded(
                                          child: BottomButton(
                                              label: 'create',
                                              enabled: true,
                                              onPressed: () {
                                                if (_ableToSend(
                                                    action: 'create')) {
                                                  _produceCreateModal(context);
                                                }
                                              }))
                                    else if (locationState.path ==
                                        '/manage/holding')
                                      Expanded(
                                          child: BottomButton(
                                        label: 'reissue',
                                        enabled: true,
                                        onPressed: () {
                                          if (_ableToSend(action: 'reissue')) {
                                            _gotoReissue();
                                          }
                                        },
                                      ))
                                    else
                                      Expanded(
                                          child: BottomButton(
                                        label: 'create?',
                                        enabled: false,
                                        onPressed: () {},
                                      ))
                                  ]
                                : <Widget>[
                                    Expanded(
                                        child: BottomButton(
                                      enabled: false,
                                      label: 'buy',
                                      onPressed: () {},
                                    )),
                                    Expanded(
                                        child: BottomButton(
                                      label: 'sell',
                                      enabled: false,
                                      onPressed: () {},
                                    ))
                                  ]))
                        .intersperse(const SizedBox(width: 16))
                        .toList(),
                    //)
                  )));

  Future<void> _gotoReissue() async {
    final cubit = components.cubits.simpleReissueForm;
    final symbol = Symbol(components.cubits.location.state.symbol!);
    final metadata = await cubit.getMetadataView(symbol: symbol.symbol);
    if (metadata != null) {
      cubit.update(
        type: symbol.symbolType,
        parentName: symbol.parentSymbol,
        name: symbol.shortName ?? symbol.symbol,
        memo:
            null /* not implemented on front end yet, and not available in metadata object, you'd have to go get the VoutId */,
        assetMemo: (metadata.mempoolAssociatedData ??
                    metadata.associatedData) !=
                null
            ? (metadata.mempoolAssociatedData ?? metadata.associatedData)!
                .toBs58() //.toHex()
            /*
            kralverde — 
            Traditionally, it’s b58, but for txids we want toHex. I think
            there’s code to convert based on the type somewhere in the client
            code...
            */
            : null,
        verifierString:
            metadata.mempoolVerifierString ?? metadata.verifierString,
        // don't include quantity because on reissue, quantity is additive.
        //quantity: metadata.mempoolTotalSupply ?? metadata.totalSupply,
        decimals: metadata.mempoolDivisibility ?? metadata.divisibility,
        reissuable: metadata.mempoolReissuable ?? metadata.reissuable,
        metadataView: metadata,
      );
      sail.to('/manage/reissue');
    }
  }

  bool _ableToSend({String action = 'send'}) {
    if (components.cubits.holdingsView.walletEmptyCoin) {
      streams.app.behavior.snack.add(Snack(
          delay: 0,
          positive: false,
          message:
              (components.cubits.holdingsView.state.holdingsViews.length <= 1
                      ? 'Empty wallet'
                      : 'No ${pros.settings.chainNet.symbol}') +
                  ', unable to $action.'));
      return false;
    }
    return true;
  }

  void _produceCreateModal(BuildContext context) {
    final imageDetails = ImageDetails(
        foreground: AppColors.rgb(AppColors.primary),
        background: AppColors.rgb(AppColors.lightPrimaries[1]));
    final modal = components.cubits.bottomModalSheet;
    final cubit = components.cubits.simpleCreateForm;
    modal.show(children: [
      for (final Tuple2<String, SymbolType> symbolType in [
        Tuple2('Main', SymbolType.main),
        Tuple2('Sub', SymbolType.sub),
        Tuple2('NFT', SymbolType.unique),

        /// hide these until we're ready to add verifierString support etc.
        // Tuple2('Channel', SymbolType.channel),
        // Tuple2('Restricted', SymbolType.restricted),
        // Tuple2('Qualifier', SymbolType.qualifier),
        // Tuple2('Sub Qualifier', SymbolType.qualifierSub),
      ])
        ListTile(
          onTap: () {
            modal.hide();
            cubit.reset();
            cubit.update(type: symbolType.item2);
            sail.to('/manage/create');
          },
          leading:
              //components.icons.generateIndicator(
              //        name: 'ASSET',
              //        imageDetails: imageDetails,
              //        height: 24,
              //        width: 24,
              //        assetType: symbolType.item2) ??
              components.icons.assetFromCacheOrGenerate(
                  asset: 'ASSET',
                  height: 24,
                  width: 24,
                  imageDetails: imageDetails,
                  assetType: symbolType.item2),
          title: Text(
            symbolType.item1,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        )
    ]);
  }
}

class SnackContents extends StatelessWidget {
  final Snack? snack;
  const SnackContents({Key? key, required this.snack}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (snack == null) {
      return SizedBox.shrink();
    }
    TextStyle snackStyle = style(context, snack);
    Widget snackMsg = Text(
      snack!.message,
      textAlign: TextAlign.left,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: snackStyle,
    );
    if (snack!.copy != null) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: screen.width - 32 - 40, child: snackMsg),
            SizedBox(
                width: 40,
                child: Text(
                  snack!.label ?? 'copy',
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: snackStyle,
                ))
          ]);
    }
    if (snack!.callback != null && snack!.label != null) {
      return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(width: screen.width - 32 - 40, child: snackMsg),
            GestureDetector(
                onTap: () async {
                  await snack!.callback!();
                  components.cubits.snackbar.clear();
                },
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                    width: 40,
                    child: Text(
                      snack!.label!,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: snackStyle,
                    )))
          ]);
    }
    return snackMsg;
  }
}
