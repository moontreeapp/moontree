import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/pane/cubit.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/ui/pane/page.dart';
import 'package:moontree/presentation/widgets/animations/sliding.dart';

class PaneLayer extends StatelessWidget {
  const PaneLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PaneCubit, PaneState>(
      buildWhen: (PaneState previous, PaneState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) {
        if (state.prior?.active == null && state.active) {
          return const SlideSide(
            enter: true,
            side: Side.bottom,
            child: PaneStack(),
          );
        }
        if ((state.prior?.active == null || !state.prior!.active) &&
            !state.active) {
          return const SizedBox.shrink();
        }
        if (!state.prior!.active && state.active) {
          return const SlideSide(
            enter: true,
            side: Side.bottom,
            child: PaneStack(),
          );
        }
        if (state.prior!.active && !state.active) {
          FocusScope.of(context).unfocus();
          return const SlideSide(
            enter: false,
            side: Side.bottom,
            child: PaneStack(),
          );
        }

        //if (state.prior!.active && state.active)
        return const PaneStack();
      });
}

class PaneStack extends StatelessWidget {
  const PaneStack({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
        children: [
          //PanePage(),
          DraggablePane(),
        ],
      );
}
