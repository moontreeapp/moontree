import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/presentation/ui/canvas/holding/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';

class HodingDetail extends StatelessWidget {
  const HodingDetail({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          previous.holding != current.holding ||
          previous.active != current.active ||
          (!previous.active && !current.active),
      builder: (context, state) => state.transitionWidgets(state,
          onEntering:
              //const FadeIn(delay: fadeDuration, child: HodingDetailPage()),
              const SlideOver(
                  duration: slideDuration,
                  delay: slideDuration,
                  begin: Offset(1, 0),
                  end: Offset(0, 0),
                  child: HodingDetailPage()),
          onEntered: const HodingDetailPage(), // never triggered
          onExiting: //FadeOut(
              //child:
              IgnorePointer(
                  ignoring:
                      (state.active && state.onHistory) || (!state.active),
                  //child: const HodingDetailPage())),
                  child: const SlideOver(
                      duration: slideDuration,
                      begin: Offset(0, 0),
                      end: Offset(1, 0),
                      child: HodingDetailPage())),
          onExited: const SizedBox.shrink()));
}
