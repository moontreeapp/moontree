import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/streams.dart';
import 'package:client_front/application/connection/cubit.dart';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/utils/ext.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:client_front/application/navbar/cubit.dart';
import 'package:client_front/application/location/cubit.dart';
import 'package:client_front/presentation/widgets/bottom/selection_items.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/services/services.dart'
    show sail, screen;
import 'package:client_front/presentation/components/shapes.dart' as shapes;
import 'package:client_front/presentation/components/shadows.dart' as shadows;
import 'package:client_front/presentation/components/components.dart'
    as components;

class Navbar extends StatefulWidget {
  const Navbar({Key? key}) : super(key: key);

  @override
  _NavbarState createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: animation.slideDuration,
    );
  }

  @override
  void dispose() {
    animationController.dispose();
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
            animationController.forward();
          } else if (state.previousNavbarHeight == NavbarHeight.hidden &&
              state.currentNavbarHeight == NavbarHeight.hidden) {
            animationController.value = 1.0;
          } else if (state.currentNavbarHeight == NavbarHeight.max) {
            animationController.reverse();
          }
          final maxHeight = state.showSections
              ? screen.navbar.maxHeight
              : screen.navbar.midHeight;
          return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) {
              double slide;
              if (state.currentNavbarHeight == NavbarHeight.hidden ||
                  (state.currentNavbarHeight == NavbarHeight.max &&
                      state.previousNavbarHeight == NavbarHeight.hidden)) {
                slide = maxHeight * animationController.value;
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
                          const SizedBox(height: 6),
                          Padding(
                              padding: EdgeInsets.zero,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  //sectorIcon(appContext: AppContext.wallet),
                                  //sectorIcon(appContext: AppContext.manage),
                                  //sectorIcon(appContext: AppContext.swap),
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
              );
            },
          );
        },
      );
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
                  BlocBuilder<HoldingsViewCubit, HoldingsViewState>(
                      builder: (BuildContext context,
                              HoldingsViewState holdingState) =>
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
                                          enabled:
                                              connectionState.isConnected &&
                                                  !components
                                                      .cubits
                                                      .holdingsView
                                                      .walletEmptyCoin,
                                          disabledOnPressed: () {
                                            if (!connectionState.isConnected) {
                                              streams.app.snack.add(Snack(
                                                  message:
                                                      'Not connected to network'));
                                            } else if (components.cubits
                                                .holdingsView.walletEmptyCoin) {
                                              streams.app.snack.add(Snack(
                                                  message:
                                                      'This wallet has no coin, unable to send.'));
                                            }
                                          },
                                          onPressed: () =>
                                              sail.to('/wallet/send'),
                                        )),
                                        Expanded(
                                            child: BottomButton(
                                          label: 'receive',
                                          onPressed: () =>
                                              sail.to('/wallet/receive'),
                                        ))
                                      ]
                                    : locationState.section == Section.manage
                                        ? <Widget>[
                                            Expanded(
                                                child: BottomButton(
                                              label: 'create',
                                              enabled: false,
                                              onPressed: () =>
                                                  _produceCreateModal(context),
                                            ))
                                          ]
                                        : <Widget>[
                                            Expanded(
                                                child: BottomButton(
                                              enabled: false,
                                              onPressed: () =>
                                                  _produceCreateModal(context),
                                            )),
                                            Expanded(
                                                child: BottomButton(
                                              label: 'sell',
                                              enabled: false,
                                              onPressed: () =>
                                                  _produceCreateModal(context),
                                            ))
                                          ]))
                                .intersperse(const SizedBox(width: 16))
                                .toList(),
                          ))));

  void _produceCreateModal(BuildContext context) {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }
}
