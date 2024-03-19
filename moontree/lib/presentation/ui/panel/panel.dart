import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/panel/cubit.dart';
import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/presentation/layers/panel/page.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';
import 'package:moontree/presentation/widgets/animations/sliding.dart';

class PanelLayer extends StatelessWidget {
  const PanelLayer({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<PanelCubit, PanelState>(
      buildWhen: (PanelState previous, PanelState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) {
        if (state.prior?.active == null && state.active) {
          return FadeIn(child: PanelStack());
        }
        if ((state.prior?.active == null || !state.prior!.active) &&
            !state.active) {
          return const SizedBox.shrink();
        }
        if (!state.prior!.active && state.active) {
          return SlideSide(
            enter: true,
            side: Side.bottom,
            child: PanelStack(),
          );
        }
        if (state.prior!.active && !state.active) {
          FocusScope.of(context).unfocus();
          return SlideSide(
            enter: false,
            side: Side.bottom,
            child: PanelStack(),
          );
        }

        //if (state.prior!.active && state.active)
        return PanelStack();
      });
}

class PanelStack extends StatelessWidget {
  const PanelStack({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          PanelPage(),
        ],
      );
}
