import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:client_back/streams/app.dart';
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
                      boxShadow: shadows.navBar,
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
  Widget build(BuildContext context) =>
      BlocBuilder<LocationCubit, LocationCubitState>(
          builder: (BuildContext context, LocationCubitState state) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ((state.section == Section.wallet
                        ? <Widget>[
                            //if (walletIsEmpty &&
                            //    !walletHasTransactions &&
                            //    streams.import.result.value == null)
                            //  BottomButton(
                            //    label: 'import',
                            //    onPressed: () async {
                            //      sail.to('/restore/import');
                            //    },
                            //  )
                            //else
                            Expanded(
                                child: BottomButton(
                              label: 'send',
                              enabled: false,
                              //!walletIsEmpty &&
                              //    connectionStatus == ConnectionStatus.connected,
                              //disabledOnPressed: () {
                              //  if (connectionStatus != ConnectionStatus.connected) {
                              //    streams.app.snack
                              //        .add(Snack(message: 'Not connected to network'));
                              //  } else if (walletIsEmpty) {
                              //    streams.app.snack.add(Snack(
                              //        message: 'This wallet has no coin, unable to send.'));
                              //  } else {
                              //    streams.app.snack
                              //        .add(Snack(message: 'Claimed your EVR first.'));
                              //  }
                              //},
                              onPressed: () => sail.to('/wallet/send'),
                            )),
                            Expanded(
                                child: BottomButton(
                              label: 'receive',
                              onPressed: () => sail.to('/wallet/receive'),
                            ))
                          ]
                        : state.section == Section.manage
                            ? <Widget>[
                                Expanded(
                                    child: BottomButton(
                                  label: 'create',
                                  enabled: false,
                                  onPressed: () => _produceCreateModal(context),
                                ))
                              ]
                            : <Widget>[
                                Expanded(
                                    child: BottomButton(
                                  enabled: false,
                                  onPressed: () => _produceCreateModal(context),
                                )),
                                Expanded(
                                    child: BottomButton(
                                  label: 'sell',
                                  enabled: false,
                                  onPressed: () => _produceCreateModal(context),
                                ))
                              ]))
                    .intersperse(const SizedBox(width: 16))
                    .toList(),
              ));

  void _produceCreateModal(BuildContext context) {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }
}













/* -------------------------------------------------------------------------- */
// Old But Good Working Code
/* -------------------------------------------------------------------------- */

// class _NavbarState extends State<Navbar> {
//   final int _currentIndex = 0;
//   final int _tappedIndex = 0;
//   final Sailor _sail = const Sailor();

//   void updateState() => setState(() {
//         // _currentIndex = _tappedIndex;
//       });

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NavbarCubit, NavbarCubitState>(
//       builder: (context, state) {
//         // Provide Navbar Section View Cubit
//         final navbarSectionViewCubit =
//             BlocProvider.of<NavbarSectionViewCubit>(context);

//         if (state is NavbarCubitStateHidden) {
//           return const SizedBox.shrink();
//         } else {
//           return AnimatedContainer(
//             duration: const Duration(milliseconds: 200),
//             curve: Curves.linear,
//             width: MediaQuery.of(context).size.width,
//             height: state.navbarHeight,
//             clipBehavior: Clip.antiAlias,
//             decoration: const BoxDecoration(
//               boxShadow: [
//                 BoxShadow(
//                     color: AppColors.primary,
//                     offset: Offset(0, 3),
//                     spreadRadius: 3,
//                     blurRadius: 3)
//               ],
//               color: Colors.white,
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(16),
//                 topRight: Radius.circular(16),
//               ),
//             ),
//             // After Animation has Completed, Show Navbar's Section Widget
//             // onEnd: () => print('On End'),
//             onEnd: () {
//               if (state is NavbarCubitStateMax) {
//                 return navbarSectionViewCubit.show();
//               }
//             },
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       // children: [Text('Column 1')],
//                       children: [
//                         Container(
//                           alignment: Alignment.center,
//                           // decoration: BoxDecoration(color: AppColors.primary),
//                           height: state is NavbarCubitStateMid
//                               ? screen.navbarMidHeight
//                               : maxHeight / 2,
//                           width: MediaQuery.of(context).size.width / 2,

//                           child: ElevatedButton(
//                               onPressed: () {}, child: const Text('Send')),
//                         )
//                       ],
//                     ),
//                     Column(
//                       children: [
//                         Column(
//                           // children: [Text('Column 1')],
//                           children: [
//                             Container(
//                               alignment: Alignment.center,
//                               // decoration: BoxDecoration(color: AppColors.primary),
//                               height:
//                                   state is NavbarCubitStateMid
//                                       ? screen.navbarMidHeight
//                                       : maxHeight / 2,
//                               width: MediaQuery.of(context).size.width / 2,
//                               child: ElevatedButton(
//                                   onPressed: () {},
//                                   child: const Text('Receive')),
//                             )
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//                 BlocBuilder<NavbarSectionViewCubit, NavbarSectionViewState>(
//                   builder: (context, navbarViewState) {
//                     if (navbarViewState.showSections == true) {
//                       return const AnimatedOpacity(
//                         opacity: 1.0,
//                         duration: Duration(milliseconds: 100),
//                         child: NavbarMax(),
//                       );
//                     } else {
//                       return const AnimatedOpacity(
//                         opacity: 0,
//                         duration: Duration(milliseconds: 0),
//                         // Returns Empty SizedBox So That Nothing Is Displayed
//                         child: SizedBox.shrink(),
//                         // onEnd: () => navbarHeightCubit.mid(),
//                       );
//                     }
//                   },
//                 )
//               ],
//             ),
//           );
//         }
//       },
//     );
//   }
// }

// class NavbarMax extends StatelessWidget {
//   const NavbarMax({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           children: [
//             Container(
//               alignment: Alignment.center,
//               // decoration: BoxDecoration(color: Colors.green),
//               height: maxHeight / 2,
//               width: MediaQuery.of(context).size.width / 3,
//               child: const Icon(Icons.money),
//             )
//           ],
//         ),
//         Column(
//           children: [
//             Container(
//               alignment: Alignment.center,
//               // decoration: BoxDecoration(color: Colors.green),
//               height: maxHeight / 2,
//               width: MediaQuery.of(context).size.width / 3,
//               child: const Icon(Icons.add),
//             )
//           ],
//         ),
//         Column(
//           children: [
//             Container(
//               alignment: Alignment.center,
//               // decoration: BoxDecoration(color: Colors.green),
//               height: maxHeight / 2,
//               width: MediaQuery.of(context).size.width / 3,
//               child: const Icon(Icons.swap_horiz),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }

