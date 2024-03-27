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

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller,
      shrinkWrap: true,
      itemCount: 48,
      itemBuilder: (context, index) => Transaction(
          display: TransactionDisplay(
              incoming: true,
              when: DateTime.now(),
              sats: Sats(() {
                final x = pow(index, index ~/ 4.2) as int;
                if (x > 0 && x < 2100000000000000000) {
                  return x;
                }
                return index;
              }()))));
}

class Transaction extends StatelessWidget {
  final TransactionDisplay display;
  const Transaction({super.key, required this.display});

  @override
  Widget build(BuildContext context) => ListTile(
        //dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
        title: SizedBox(
            width: screen.width - (16 + 16 + screen.iconLarge + 16),
            child: Text(display.sats.toCoin.humanString(),
                style: Theme.of(context).textTheme.body1.copyWith(height: 0))),
        subtitle: Container(
            width: screen.width - (16 + 16 + screen.iconLarge + 16),
            //color: Colors.red,
            child: Text('today',
                textAlign: TextAlign.start,
                style: Theme.of(context).textTheme.body2.copyWith(
                      height: 0,
                      color: Colors.black38,
                    ))),
        trailing: Container(
          width: screen.iconLarge,
          alignment: Alignment.centerRight,
          child: SvgPicture.asset(
            '${TransactionIcons.base}/${true ? 'incoming' : 'outgoing'}.${TransactionIcons.ext}',
            height: screen.iconMedium,
            width: screen.iconMedium,
            fit: BoxFit.contain,
            alignment: Alignment.center,
          ),
        ),
      );
}
