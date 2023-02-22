import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/back/cubit.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;

class BackContainer extends StatelessWidget {
  const BackContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BackContainerCubit, BackContainerCubitState>(
          builder: (context, state) => BackContainerView(
                height: state.height,
                child: state.child,
              ));
}

class BackContainerView extends StatelessWidget {
  final Widget? child;
  final double? height;
  const BackContainerView({Key? key, this.height, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
      width: MediaQuery.of(context).size.width,
      color: AppColors.primary,
      height: height,
      alignment: Alignment.topCenter,
      child: child
      //AnimatedSwitcher(
      //  duration: animation.fadeDuration,
      //  transitionBuilder: (Widget child, Animation<double> animation) =>
      //      FadeTransition(
      //          opacity: animation.drive(Tween<double>(begin: 0, end: 1)
      //              .chain(CurveTween(curve: Curves.easeInOutCubic))),
      //          child: child),
      //  child: state.child,
      //)),
      );
}