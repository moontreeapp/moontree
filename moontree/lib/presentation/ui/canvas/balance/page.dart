import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/canvas/balance/cubit.dart';
import 'package:moontree/presentation/theme/text.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';

class BalancePage extends StatelessWidget {
  const BalancePage({super.key});

  @override
  Widget build(BuildContext context) => Container(
      width: screen.width,
      height: screen.height,
      padding: EdgeInsets.only(top: screen.appbar.height),
      alignment: Alignment.topCenter,
      child: Container(
          width: screen.width,
          height: screen.canvas.midHeight,
          alignment: Alignment.center,
          child: const AnimatedBalance()));
}

class AnimatedBalance extends StatelessWidget {
  const AnimatedBalance({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<BalanceCubit, BalanceState>(
      buildWhen: (BalanceState previous, BalanceState current) =>
          current.active && previous.faded != current.faded,
      builder: (context, state) => AnimatedOpacity(
          duration: fadeDuration,
          curve: Curves.easeInOutCubic,
          opacity: state.faded ? .12 : 1,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.portfolioHead, style: AppText.wholeFiat),
                  if (state.portfolioTail != '.00')
                    Text(state.portfolioTail, style: AppText.partFiat),
                ]),
            Text('Portfolio Value', style: AppText.usdHolding),
          ])));
}
