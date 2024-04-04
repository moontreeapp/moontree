import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/cubits/canvas/holding/cubit.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/presentation/widgets/animations/hiding.dart';
import 'package:moontree/services/services.dart' show maestro, screen;
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/presentation/widgets/assets/icons.dart';

class HodingDetailPage extends StatelessWidget {
  const HodingDetailPage({super.key});

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
          child: const AnimatedCoinSpec()));
}

class AnimatedCoinSpec extends StatelessWidget {
  const AnimatedCoinSpec({super.key});

  Widget assetIcon() => Container(
      width: screen.width,
      alignment: Alignment.center,
      child: Container(
        height: screen.iconHuge,
        width: screen.iconHuge,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.primary60,
          borderRadius: BorderRadius.circular(100),
        ),
        //child: SvgPicture.asset(
        //  '${TransactionIcons.base}/send.${TransactionIcons.ext}',
        //  alignment: Alignment.center,
        //),
      ));

  Widget assetValues() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('whole.', style: AppText.wholeHolding),
          Text('part', style: AppText.partHolding),
        ]),
        Text('\$ usd', style: AppText.usdHolding),
      ]);

  Widget buttons() => SizedBox(
      width: screen.width * .8,
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        GestureDetector(
            onTap: () => maestro.activateSend(),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                height: screen.iconLarge,
                width: screen.iconLarge,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary60,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: SvgPicture.asset(
                  '${TransactionIcons.base}/send.${TransactionIcons.ext}',
                  alignment: Alignment.center,
                ),
              ),
              const SizedBox(height: 4),
              Text('send', style: AppText.labelHolding),
            ])),
        //SizedBox(width: screen.canvas.wSpace),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: screen.iconLarge,
            width: screen.iconLarge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary60,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              '${TransactionIcons.base}/receive.${TransactionIcons.ext}',
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 4),
          Text('receive', style: AppText.labelHolding),
        ]),
        //SizedBox(width: screen.canvas.wSpace),
        Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            height: screen.iconLarge,
            width: screen.iconLarge,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary60,
              borderRadius: BorderRadius.circular(100),
            ),
            child: SvgPicture.asset(
              '${TransactionIcons.base}/swap.${TransactionIcons.ext}',
              alignment: Alignment.center,
            ),
          ),
          const SizedBox(height: 4),
          Text('swap', style: AppText.labelHolding),
        ]),
      ]));

  /// AnimatedPositions solution:
  @override
  Widget build(BuildContext context) => BlocBuilder<HoldingCubit, HoldingState>(
      buildWhen: (HoldingState previous, HoldingState current) =>
          current.active && previous.send != current.send,
      builder: (context, state) {
        return Stack(alignment: Alignment.topCenter, children: [
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: state.send ? 24 : 4,
              child: assetIcon()),
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: state.send
                  ? 24 + screen.iconHuge + 24
                  : 4 + screen.iconHuge + 16,
              child: assetValues()),
          Positioned(
              bottom: 24, child: Hide(hidden: state.send, child: buttons())),
        ]);
      });
}
