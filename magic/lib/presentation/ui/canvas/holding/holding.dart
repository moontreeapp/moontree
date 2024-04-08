import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/presentation/ui/canvas/holding/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';

class HodingDetail extends StatelessWidget {
  const HodingDetail({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) => state.transitionWidgets(state,
          onEntering:
              const FadeIn(delay: fadeDuration, child: HodingDetailPage()),
          onEntered: const HodingDetailPage(), // never triggered
          onExiting: FadeOut(
              child: IgnorePointer(
                  ignoring: (state.active && !state.send) || (!state.active),
                  child: const HodingDetailPage())),
          onExited: const SizedBox.shrink()));
}
