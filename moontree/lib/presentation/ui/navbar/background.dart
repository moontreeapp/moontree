import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/create/camera/cubit.dart';
import 'package:moontree/cubits/navbar/cubit.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/layers/navbar/components/background.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/widgets/animations/deblur.dart';

class NavBackground extends StatefulWidget {
  const NavBackground({super.key});

  @override
  _NavBackgroundState createState() => _NavBackgroundState();
}

class _NavBackgroundState extends State<NavBackground> {
  bool beenBlurred = false;

  @override
  Widget build(BuildContext context) =>
      // GestureDetector(
      //   onVerticalDragEnd: (details) {
      //   print('details.primaryVelocity ${details.primaryVelocity}');
      //   if (cubits.navbar.state.currentNavbarHeight == NavbarHeight.max &&
      //       (details.primaryVelocity ?? 0) > 300) {
      //     cubits.navbar.mid();
      //     if (cubits.navbar.state.extendedSelected == ExtendedNavbarItem.say) {
      //       // if txt empty tell cubit selected item is 1 rather than 0
      //       Future.delayed(animation.slideDuration, () {
      //         if (cubits.navbar.state.extendedSelected ==
      //                 ExtendedNavbarItem.say &&
      //             cubits.commentsList.state.comment == '') {
      //           cubits.navbar.update(
      //             extendedSelected: ExtendedNavbarItem.none,
      //             selectedIndex: 1,
      //             previousNavbarHeight: cubits.navbar.state.currentNavbarHeight,
      //           );
      //           cubits.navbar.state.scroll?.animateTo(screen.navbar.itemWidth,
      //               duration: animation.slideDuration, curve: Curves.easeIn);
      //         }
      //       });
      //     }
      //   } else if (cubits.navbar.state.currentNavbarHeight ==
      //           NavbarHeight.mid &&
      //       (details.primaryVelocity ?? 0) < -1000) {
      //     cubits.navbar.max();
      //   }
      // }, onTap: () {
      //   if (cubits.navbar.state.currentNavbarHeight == NavbarHeight.mid) {
      //     cubits.navbar.max();
      //   }
      // }, child:

      BlocBuilder<CameraViewCubit, CameraViewState>(
          builder: (BuildContext context, CameraViewState homeState) {
        if (homeState.x != 0) {
          beenBlurred = true;
          return NavbarBackground(blurAmount: 10.0);
        }
        if (beenBlurred) {
          return DeBlurAnimation();
        }
        return NavbarBackground(
            color: cubits.navbar.state.navbarHeight == NavbarHeight.max
                ? AppColors.black38
                : AppColors.black24);
      });
}

class AnimatedNavbarBackground extends StatefulWidget {
  final double height;
  final Duration duration;
  final bool out;

  AnimatedNavbarBackground({
    super.key,
    required this.height,
    this.duration = const Duration(seconds: 1),
    this.out = false,
  });

  @override
  _AnimatedNavbarBackgroundState createState() =>
      _AnimatedNavbarBackgroundState();
}

class _AnimatedNavbarBackgroundState extends State<AnimatedNavbarBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<List<double>> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    ); //..repeat(reverse: true);

    _animation = ListTween(
      begin: [
        1, 0, 0, 0, 0, // White
        0, 1, 0, 0, 0,
        0, 0, 1, 0, 0,
        0, 0, 0, 1, 0,
      ],
      end: [
        0.2126, 0.7152, 0.0722, 0.0, 0, // Grey
        0.2126, 0.7152, 0.0722, 0.0, 0,
        0.2126, 0.7152, 0.0722, 0.0, 0,
        0.0000, 0.0000, 0.0000, 0.9, 0,
      ],
    ).animate(_controller);
    if (widget.out) {
      _controller.reverse(from: 1);
    } else {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return NavbarBackground(
          height: widget.height,
          color: Colors.transparent,
          imageFilter: ColorFilter.matrix(_animation.value),
        );
      },
    );
  }
}

class ListTween extends Tween<List<double>> {
  ListTween({List<double>? begin, List<double>? end})
      : super(begin: begin, end: end);

  @override
  List<double> lerp(double t) {
    return List.generate(begin!.length, (index) {
      return lerpDouble(begin![index], end![index], t)!;
    });
  }
}
