import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_front/presentation/widgets/front_drop.dart';
import 'package:client_front/application/front/height/cubit.dart';
import 'package:client_front/presentation/services/services.dart' show beamer;
import 'package:client_front/presentation/utilities/animation.dart'
    as animation;

class FrontContainer extends StatelessWidget {
  const FrontContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<FrontContainerHeightCubit, FrontContainerHeightCubitState>(
          builder: (context, state) => Container(
                alignment: Alignment.bottomCenter,
                child: AnimatedContainer(
                  height: state.height,
                  width: MediaQuery.of(context).size.width,
                  duration: animation.slideDuration,
                  curve: Curves.easeInOut,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      FrontDrop(
                          color:
                              state.hide ? Colors.transparent : Colors.white),
                      beamer.front()
                    ],
                  ),
                ),
              ));
}
