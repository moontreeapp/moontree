import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/application/front/cubit.dart';
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;

class FrontContainer extends StatelessWidget {
  final Widget? child;
  const FrontContainer({Key? key, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FrontContainerCubit, FrontContainerCubitState>(
          builder: (context, state) => Container(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  height: state.height,
                  width: MediaQuery.of(context).size.width,
                  duration: animation.fadeDuration,
                  curve: Curves.easeInOut,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      FrontCurve(
                          color:
                              state.hide ? Colors.transparent : Colors.white),
                      AnimatedOpacity(
                          duration: animation.fadeDuration,
                          opacity: state.hideContent ? 0.0 : 1.0,
                          child: child ?? SizedBox.shrink()),
                    ],
                  ),
                ),
              ));
}
