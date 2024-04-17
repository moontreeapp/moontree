import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/animations/hiding.dart';
import 'package:magic/services/services.dart' show maestro, screen;
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';

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
            //color: AppColors.primary60,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Image.asset(LogoIcons.evr) // TODO: get from cubit
          //SvgPicture.asset(
          //  LogoIcons.evr,
          //  alignment: Alignment.center,
          //),
          ));

  Widget assetValues() =>
      Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(cubits.holding.state.whole, style: AppText.wholeHolding),
          Text(cubits.holding.state.part, style: AppText.partHolding),
        ]),
        Text(cubits.holding.state.usd, style: AppText.usdHolding),
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
          current.active && previous.section != current.section,
      builder: (context, state) {
        double iconTop = 4;
        double valueTop = 4 + screen.iconHuge + 16;

        if (state.section == HoldingSection.none) {
          iconTop = 4;
          valueTop = 4 + screen.iconHuge + 16;
        } else if (state.section == HoldingSection.send) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5)) +
              screen.iconHuge +
              8;
        } else if (state.section == HoldingSection.receive) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5)) +
              screen.iconHuge +
              8;
        } else if (state.section == HoldingSection.swap) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5)) +
              screen.iconHuge +
              8;
        } else if (state.section == HoldingSection.transaction) {
          iconTop = screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5);
          valueTop = (screen.canvas.midHeight / 2 - (screen.iconHuge * 1.5)) +
              screen.iconHuge +
              8;
          //iconTop = 24;
          //valueTop = 24 + screen.iconHuge + 24;
        }
        return Stack(alignment: Alignment.topCenter, children: [
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: iconTop,
              child: assetIcon()),
          AnimatedPositioned(
              duration: slideDuration,
              curve: Curves.easeInOutCubic,
              top: valueTop,
              child: assetValues()),
          Positioned(
              bottom: 24,
              child: Hide(
                  hidden: state.section != HoldingSection.none,
                  child: buttons())),
        ]);
      });
}
