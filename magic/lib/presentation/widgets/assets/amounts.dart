import 'package:flutter/material.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/services/services.dart';

class CoinBalanceView extends StatelessWidget {
  final Coin coin;
  final TextStyle? wholeStyle;
  final TextStyle? partOneStyle;
  final TextStyle? partTwoStyle;
  final TextStyle? partThreeStyle;
  const CoinBalanceView({
    super.key,
    required this.coin,
    this.wholeStyle,
    this.partOneStyle,
    this.partTwoStyle,
    this.partThreeStyle,
  });

  @override
  Widget build(BuildContext context) => Container(
      alignment: Alignment.bottomCenter,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(coin.whole(), style: wholeStyle ?? AppText.wholeHolding),
            if (coin.sats > 0) ...[
              Text(coin.partOne(),
                  style: partOneStyle ??
                      AppText.partHolding.copyWith(
                          //height: 1.625 + .15
                          )),
              const SizedBox(width: 4),
              Text(coin.partTwo(),
                  style: partTwoStyle ??
                      AppText.partHolding.copyWith(
                          //height: 1.625 + .3,
                          //fontSize: 12,
                          //height: 1.625 + .6,
                          //fontSize: 10,
                          )),
              const SizedBox(width: 4),
              Text(coin.partThree(),
                  style: partThreeStyle ??
                      AppText.partHolding.copyWith(
                          // how do I align at with bottom?
                          //height: 1.625 + .6,
                          //fontSize: 10,

                          ))
            ],
          ]));
}

class CoinView extends StatelessWidget {
  final Coin coin;
  final TextStyle? wholeStyle;
  final TextStyle? partOneStyle;
  final TextStyle? partTwoStyle;
  final TextStyle? partThreeStyle;
  final DifficultyMode? mode;
  final TextAlign textAlign;
  const CoinView({
    super.key,
    required this.coin,
    this.wholeStyle,
    this.partOneStyle,
    this.partTwoStyle,
    this.partThreeStyle,
    this.mode,
    this.textAlign = TextAlign.start,
  });

  @override
  Widget build(BuildContext context) =>
      (mode ?? cubits.menu.state.mode) == DifficultyMode.easy
          ? Text(coin.simplified(),
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(height: 0, color: AppColors.black60))
          : RichText(
              textAlign: textAlign,
              overflow: TextOverflow.ellipsis,
              softWrap: false,
              text: TextSpan(
                style: wholeStyle ??
                    Theme.of(context)
                        .textTheme
                        .body1
                        .copyWith(height: 0, color: AppColors.black60),
                children: <TextSpan>[
                  TextSpan(text: coin.whole()),
                  if (coin.sats > 0) ...[
                    TextSpan(
                        text: coin.partOne(),
                        style: partOneStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                height: 0,
                                fontSize: 14,
                                color: AppColors.black38)),
                    TextSpan(
                        text: coin.partTwo(),
                        style: partTwoStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                //height: 1.625 + .3,
                                //fontSize: 12,
                                height: 0,
                                fontSize: 10,
                                color: AppColors.black38)),
                    TextSpan(
                        text: coin.partThree(),
                        style: partThreeStyle ??
                            Theme.of(context).textTheme.body1.copyWith(
                                // how do I align at with bottom?
                                height: 0,
                                fontSize: 10,
                                color: AppColors.black38))
                  ],
                ],
              ),
            );
}

class CoinSplitView extends StatelessWidget {
  final Coin coin;
  final TransactionDisplay display;
  const CoinSplitView({
    super.key,
    required this.coin,
    required this.display,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
      width: screen.width * .375,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            RichText(
                textAlign: TextAlign.end,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(
                    style: Theme.of(context).textTheme.body1,
                    children: <TextSpan>[
                      TextSpan(
                          text:
                              '${display.incoming ? '+' : '-'}${coin.whole()}',
                          style: Theme.of(context).textTheme.body1.copyWith(
                                fontWeight:
                                    display.incoming ? FontWeight.bold : null,
                                color: display.incoming
                                    ? AppColors.success
                                    : AppColors.black60,
                              )),
                      TextSpan(
                          text: coin.partOne(),
                          style: Theme.of(context).textTheme.body1.copyWith(
                                height: 0,
                                color: display.incoming
                                    ? AppColors.success
                                    : AppColors.black60,
                              )),
                    ])),
            Text(coin.spacedEnding(),
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.body1.copyWith(
                      height: 0,
                      fontSize: 10,
                      color: display.incoming
                          ? AppColors.success
                          : AppColors.black60,
                    )),
            const SizedBox(height: 2),
          ]));
}

class FiatView extends StatelessWidget {
  final Fiat fiat;
  final TextStyle? wholeStyle;
  final TextStyle? partStyle;
  const FiatView({
    super.key,
    required this.fiat,
    this.wholeStyle,
    this.partStyle,
  });

  @override
  Widget build(BuildContext context) =>
      cubits.menu.state.mode == DifficultyMode.easy
          ? Text(fiat.simplified(),
              textAlign: TextAlign.right,
              style: Theme.of(context)
                  .textTheme
                  .body1
                  .copyWith(color: AppColors.black60))
          : (String humanString) {
              return RichText(
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
                text: TextSpan(children: [
                  TextSpan(
                    text: humanString.split('.').first,
                    style: wholeStyle ??
                        Theme.of(context)
                            .textTheme
                            .body1
                            .copyWith(height: 0, color: AppColors.black60),
                  ),
                  if (humanString != '\$0.00')
                    TextSpan(
                      text: '.${humanString.split('.').last}',
                      style: wholeStyle ??
                          Theme.of(context)
                              .textTheme
                              .body1
                              .copyWith(height: 0, color: AppColors.black60),
                    ),
                ]),
              );
            }(fiat.humanString());
}
