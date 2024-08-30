import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/balance/cubit.dart';
import 'package:magic/presentation/ui/canvas/balance/page.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/fading.dart';
import 'package:magic/presentation/widgets/animations/sliding.dart';

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<BalanceCubit, BalanceState>(
      builder: (BuildContext context, BalanceState state) =>
          state.transitionWidgets(state,
              onEntering: !state.initialized
                  ? const FadeIn(delay: fadeDuration, child: BalancePage())
                  : const SlideOver(
                      duration: slideDuration,
                      delay: slideDuration,
                      begin: Offset(-1, 0),
                      end: Offset(0, 0),
                      child: BalancePage()),
              onEntered: const BalancePage(), // never triggered
              onExiting: IgnorePointer(
                  ignoring: !state.active,
                  //child: const FadeOut(child: BalancePage())),
                  child: const SlideOver(
                      duration: slideDuration,
                      begin: Offset(0, 0),
                      end: Offset(-1, 0),
                      child: BalancePage())),
              onExited: const SizedBox.shrink()));
}
