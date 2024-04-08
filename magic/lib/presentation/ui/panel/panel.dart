import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/panel/cubit.dart';
import 'package:magic/domain/concepts/side.dart';
import 'package:magic/presentation/ui/panel/page.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';

class PanelLayer extends StatelessWidget {
  const PanelLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PanelCubit, PanelState>(
      buildWhen: (PanelState previous, PanelState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) {
        if (state.prior?.active == null && state.active) {
          return const FadeIn(child: PanelStack());
        }
        if ((state.prior?.active == null || !state.prior!.active) &&
            !state.active) {
          return const SizedBox.shrink();
        }
        if (!state.prior!.active && state.active) {
          return const SlideSide(
            enter: true,
            side: Side.bottom,
            child: PanelStack(),
          );
        }
        if (state.prior!.active && !state.active) {
          FocusScope.of(context).unfocus();
          return const SlideSide(
            enter: false,
            side: Side.bottom,
            child: PanelStack(),
          );
        }

        //if (state.prior!.active && state.active)
        return const PanelStack();
      });
}

class PanelStack extends StatelessWidget {
  const PanelStack({super.key});

  @override
  Widget build(BuildContext context) => const Stack(
        children: [
          PanelPage(),
        ],
      );
}

/// example usage
// cubits.panel.update(
//  child: (ScrollController scroller) =>
//  ChooseCompetitors(scroller: scroller));
// cubits.panel.update(active: true);