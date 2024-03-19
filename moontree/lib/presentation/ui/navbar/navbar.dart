import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/utils/animation.dart' as animation;
import 'package:moontree/presentation/layers/navbar/components/draggable.dart';
import 'package:moontree/presentation/layers/navbar/components/sections.dart';

class NavbarLayer extends StatefulWidget {
  const NavbarLayer({Key? key}) : super(key: key);

  @override
  _NavbarLayerState createState() => _NavbarLayerState();
}

class _NavbarLayerState extends State<NavbarLayer>
    with TickerProviderStateMixin {
  late AnimationController animationController;
  late AnimationController fadeController;
  late AnimationController snackbarController;
  final GlobalKey<DraggableSnappableSheetState> navSheetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: animation.slideDuration,
    );
    fadeController = AnimationController(
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
    fadeController.dispose();
    snackbarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<NavbarCubit, NavbarState>(
          builder: (BuildContext context, NavbarState state) {
        // if (state.navbarHeight == NavbarHeight.none) {
        //   return const SizedBox.shrink();
        // }
        // if (state.navbarHeight == NavbarHeight.hidden &&
        //     state.currentHeight != NavbarHeight.hidden) {
        //   navSheetKey.currentState?.animateToPosition(
        //       screen.app.height - screen.navbar.hiddenHeight);
        // } else if (state.navbarHeight == NavbarHeight.min &&
        //     state.currentHeight != NavbarHeight.min) {
        //   navSheetKey.currentState
        //       ?.animateToPosition(screen.app.height - screen.navbar.minHeight);
        // } else if (state.navbarHeight == NavbarHeight.mid &&
        //     state.currentHeight != NavbarHeight.mid) {
        //   // might want to separately key this off a choice in the cubit
        //   navSheetKey.currentState?.setHeightRange(
        //       screen.app.height - screen.navbar.navHeight,
        //       screen.app.height - screen.navbar.minHeight);
        //   navSheetKey.currentState
        //       ?.animateToPosition(screen.app.height - screen.navbar.midHeight);
        // } else if (state.navbarHeight == NavbarHeight.nav &&
        //     state.currentHeight != NavbarHeight.nav) {
        //   navSheetKey.currentState
        //       ?.animateToPosition(screen.app.height - screen.navbar.navHeight);
        // } else if (state.navbarHeight == NavbarHeight.max &&
        //     state.currentHeight != NavbarHeight.max) {
        //   navSheetKey.currentState?.setHeightRange();
        //   navSheetKey.currentState
        //       ?.animateToPosition(screen.app.height - screen.navbar.maxHeight);
        // } else if (state.navbarHeight == NavbarHeight.full &&
        //     state.currentHeight != NavbarHeight.full) {
        //   navSheetKey.currentState?.setHeightRange();
        //   navSheetKey.currentState
        //       ?.animateToPosition(screen.app.height - screen.navbar.fullHeight);
        // }
        // return Stack(children: [
        //   if (state.navbarHeight == NavbarHeight.max)
        //     GestureDetector(
        //         // make the exit function key off the change in cubit.
        //         onTap: () {
        //           cubits.navbar.mid();
        //           Future.delayed(animation.slideDuration, () {
        //             if (cubits.navbar.state.extendedSelected ==
        //                 ExtendedNavbarItem.say) {
        //               cubits.emojiCarousel.update(selectedIndex: 1);
        //               cubits.navbar.update(
        //                 extendedSelected: ExtendedNavbarItem.none,
        //               );
        //               cubits.emojiCarousel.state.scroll?.animateTo(
        //                   screen.navbar.itemWidth,
        //                   duration: animation.slideDuration,
        //                   curve: Curves.easeIn);
        //             }
        //           });
        //         },
        //         child: Container(color: Colors.white.withOpacity(.01))),
        //   if (state.navOnly) NavbarSections(section: state.section),
        // ]);
        if (state.navOnly) {
          return NavbarSections(section: state.section);
        } else {
          return const SizedBox.shrink();
        }
      });
}
