import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/application/back/cubit.dart';

class BackContainer extends StatelessWidget {
  const BackContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<BackContainerCubit, BackContainerCubitState>(
        builder: (context, state) => Container(
            width: MediaQuery.of(context).size.width,
            height: state.height,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  FadeTransition(
                      opacity: animation.drive(Tween<double>(begin: 0, end: 1)
                          .chain(CurveTween(curve: Curves.easeInOutCubic))),
                      child: child),
              child: state.child,
            )),
      );
}
