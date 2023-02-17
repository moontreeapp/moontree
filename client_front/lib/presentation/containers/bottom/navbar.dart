import 'package:client_front/presentation/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/navbar/height/cubit.dart';
import 'package:client_front/presentation/services/sailor.dart';
import 'package:client_front/presentation/services/services.dart' as uiservices;
import 'package:client_front/presentation/services/services.dart' show sailor;

class BottomNavigationBarWidget extends StatefulWidget {
  const BottomNavigationBarWidget({Key? key}) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<NavbarHeightCubit, NavbarHeightCubitState>(
        builder: (BuildContext context, NavbarHeightCubitState state) {
          if (state.currentNavbarHeight == NavbarHeight.mid ||
              state.currentNavbarHeight == NavbarHeight.hidden) {
            animationController.forward();
          } else if (state.currentNavbarHeight == NavbarHeight.max) {
            animationController.reverse();
          }

          return AnimatedBuilder(
            animation: animationController,
            builder: (BuildContext context, Widget? child) {
              double slide;
              if (state.currentNavbarHeight == NavbarHeight.hidden ||
                  (state.currentNavbarHeight == NavbarHeight.max &&
                      state.previousNavbarHeight == NavbarHeight.hidden)) {
                slide = uiservices.screen.navbar.maxHeight *
                    animationController.value;
              } else {
                slide = (uiservices.screen.navbar.maxHeight / 2) *
                    animationController.value;
              }
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()..translate(0.0, slide, 0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: uiservices.screen.navbar.maxHeight,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary,
                          offset: Offset(0, 3),
                          spreadRadius: 3,
                          blurRadius: 3)
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
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
                                height: uiservices.screen.navbar.maxHeight / 2,
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
                                        uiservices.screen.navbar.maxHeight / 2,
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
                                  onTap: () async => await sailor.sailTo(
                                      section: Section.wallet),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        uiservices.screen.navbar.maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.money),
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                  onTap: () async => await sailor.sailTo(
                                      section: Section.manage),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        uiservices.screen.navbar.maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.add),
                                  ))
                            ],
                          ),
                          Column(
                            children: [
                              GestureDetector(
                                  onTap: () async => await sailor.sailTo(
                                      section: Section.swap),
                                  child: Container(
                                    alignment: Alignment.center,
                                    // decoration: BoxDecoration(color: Colors.green),
                                    height:
                                        uiservices.screen.navbar.maxHeight / 2,
                                    width:
                                        MediaQuery.of(context).size.width / 3,
                                    child: const Icon(Icons.swap_horiz),
                                  ))
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
}













/* -------------------------------------------------------------------------- */
// Old But Good Working Code
/* -------------------------------------------------------------------------- */

// class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
//   final int _currentIndex = 0;
//   final int _tappedIndex = 0;
//   final Sailor _sailor = const Sailor();

//   void updateState() => setState(() {
//         // _currentIndex = _tappedIndex;
//       });

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<NavbarHeightCubit, NavbarHeightCubitState>(
//       builder: (context, state) {
//         // Provide Navbar Section View Cubit
//         final navbarSectionViewCubit =
//             BlocProvider.of<NavbarSectionViewCubit>(context);

//         if (state is NavbarHeightCubitStateHidden) {
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
//               if (state is NavbarHeightCubitStateMax) {
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
//                           height: state is NavbarHeightCubitStateMid
//                               ? uiservices.screen.navbarMidHeight
//                               : uiservices.screen.navbar.maxHeight / 2,
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
//                                   state is NavbarHeightCubitStateMid
//                                       ? uiservices.screen.navbarMidHeight
//                                       : uiservices.screen.navbar.maxHeight / 2,
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
//               height: uiservices.screen.navbar.maxHeight / 2,
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
//               height: uiservices.screen.navbar.maxHeight / 2,
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
//               height: uiservices.screen.navbar.maxHeight / 2,
//               width: MediaQuery.of(context).size.width / 3,
//               child: const Icon(Icons.swap_horiz),
//             )
//           ],
//         ),
//       ],
//     );
//   }
// }

