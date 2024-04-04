import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/canvas/balance/cubit.dart';
import 'package:moontree/presentation/ui/canvas/balance/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/fading.dart';

class Balance extends StatelessWidget {
  const Balance({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<BalanceCubit, BalanceState>(
      builder: (BuildContext context, BalanceState state) =>
          state.transitionWidgets(state,
              onEntering:
                  const FadeIn(delay: fadeDuration, child: BalancePage()),
              onEntered: const BalancePage(), // never triggered
              onExiting: IgnorePointer(
                  ignoring: !state.active,
                  child: const FadeOut(child: BalancePage())),
              onExited: const SizedBox.shrink()));
}
