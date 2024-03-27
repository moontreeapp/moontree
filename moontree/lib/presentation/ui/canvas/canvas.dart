import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/canvas/cubit.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/ui/canvas/menu/menu.dart';
import 'package:moontree/presentation/ui/canvas/holding/holding.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class CanvasLayer extends StatelessWidget {
  const CanvasLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<CanvasCubit, CanvasState>(
      buildWhen: (CanvasState previous, CanvasState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) {
        //if (state.prior?.active == null && state.active) {
        //  return const FadeIn(child: CanvasStack());
        //}
        //if ((state.prior?.active == null || !state.prior!.active) &&
        //    !state.active) {
        //  return const SizedBox.shrink();
        //}
        //if (!state.prior!.active && state.active) {
        //  return const FadeIn(child: CanvasStack());
        //}
        //if (state.prior!.active && !state.active) {
        //  WidgetsBinding.instance.addPostFrameCallback((_) => Future.delayed(
        //      fadeDuration, () => cubits.canvas.update(active: false)));
        //  return const FadeOut(child: CanvasStack());
        //}
        ////if (state.prior!.active && state.active)
        return const CanvasStack();
      });
}

class CanvasStack extends StatelessWidget {
  const CanvasStack({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
        alignment: Alignment.topCenter,
        children: [
          Menu(),
          HodingDetail(), // mutates into send...
        ],
      );
}
