import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/home/cubit.dart';
import 'package:moontree/presentation/layers/home/split/split.dart';
import 'package:moontree/presentation/layers/home/header.dart';
import 'package:moontree/services/services.dart' show screen;
import 'package:moontree/presentation/widgets/animations/fading.dart';

class HomeLayer extends StatelessWidget {
  const HomeLayer({super.key});

  @override
  Widget build(BuildContext context) =>
      BlocBuilder<HomeLayerCubit, HomeLayerState>(
          buildWhen: (HomeLayerState previous, HomeLayerState current) =>
              previous.active != current.active ||
              (!previous.active && !current.active),
          builder: (context, state) {
            if (state.prior?.active == null && state.active) {
              return FadeIn(child: HomeSplit());
            }
            if ((state.prior?.active == null || !state.prior!.active) &&
                !state.active) {
              return const SizedBox.shrink();
            }

            /// REMOVING TRANSITIONS
            //if (!state.prior!.active && state.active) {
            //  return SlideSide(
            //    enter: true,
            //    side: Side.left,
            //    child: HomeSplit(),
            //  );
            //}
            //if (state.prior!.active && !state.active) {
            //  return SlideSide(
            //    enter: false,
            //    side: Side.left,
            //    child: HomeSplit(),
            //  );
            //}
            ////if (state.prior!.active && state.active)
            return HomeSplit();
          });
}

class HomeSplit extends StatelessWidget {
  const HomeSplit({super.key});

  @override
  Widget build(BuildContext context) => Container(
      height: screen.app.displayHeight,
      alignment: Alignment.topCenter,
      color: Colors.black,
      child: Stack(children: [
        HomeSplitLayer(),
        HomeOverlay(),
      ]));
}
