import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/cubits.dart';
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/services/services.dart' show maestro, screen;
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller,
      shrinkWrap: true,
      itemCount: cubits.transactions.state.transactions.length,
      itemBuilder: (context, index) => TransactionItem(
          display: cubits.transactions.state.transactions.elementAt(index)));
}

class TransactionItem extends StatelessWidget {
  final TransactionDisplay display;
  const TransactionItem({super.key, required this.display});

  @override
  Widget build(BuildContext context) {
    RelativeDateFormat relativeDateFormatter = RelativeDateFormat(
      Localizations.localeOf(context),
    );
    return ListTile(
        //dense: true,
        //visualDensity: VisualDensity.compact,
        onTap: () => maestro.activateTransaction(display),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: screen.iconHuge,
          height: screen.iconHuge,
          //color: Colors.red,
          alignment: Alignment.center,
          child: SvgPicture.asset(
            '${TransactionIcons.base}/${display.incoming ? 'incoming' : 'outgoing'}.${TransactionIcons.ext}',
            height: screen.iconHuge,
            width: screen.iconHuge,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
        title: SizedBox(
            width: screen.width - (16 + 16 + screen.iconLarge + 16),
            child: Text(display.humanWhen(relativeDateFormatter),
                style: Theme.of(context).textTheme.body1.copyWith(
                      height: 0,
                      color: AppColors.black87,
                    ))),
        //trailing: SizedBox(
        //    //width: screen.width - (16 + 16 + screen.iconLarge + 16),
        //    child: Text(
        //        '${display.incoming ? '+' : '-'}${display.sats.toCoin().humanString()}',
        //        style: Theme.of(context).textTheme.body1.copyWith(
        //              height: 0,
        //              color:
        //                  display.incoming ? AppColors.success : AppColors.black,
        //             ))),
        trailing: CoinSplitView(display: display, coin: display.sats.toCoin())
        //trailing: CoinView(
        //    coin: display.sats.toCoin(),
        //    wholeStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, color: AppColors.black60),
        //    partOneStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 14, color: AppColors.black60),
        //    partTwoStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 10, color: AppColors.black60),
        //    partThreeStyle: Theme.of(context)
        //        .textTheme
        //        .body1
        //        .copyWith(height: 0, fontSize: 10, color: AppColors.black60),
        //    mode: DifficultyMode.hard)
        );
  }
}
