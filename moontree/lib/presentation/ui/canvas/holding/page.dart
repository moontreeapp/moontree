import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/domain/concepts/transaction.dart';
import 'package:moontree/domain/concepts/sats.dart';
import 'package:moontree/services/services.dart' show screen;
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox.shrink(),
              Container(
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
              ),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('whole.', style: AppText.wholeHolding),
                  Text('part', style: AppText.partHolding),
                ]),
                Text('\$ usd', style: AppText.usdHolding),
              ]),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                const SizedBox.shrink(),
                const SizedBox.shrink(),
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
                const SizedBox.shrink(),
                const SizedBox.shrink(),
              ]),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
              const SizedBox.shrink(),
            ],
          ),
        ),
      );
}
