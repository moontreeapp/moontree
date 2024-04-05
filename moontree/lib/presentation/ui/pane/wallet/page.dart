import 'dart:math';
import 'package:flutter/material.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/presentation/theme/theme.dart';
import 'package:moontree/services/services.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override // TODO: get from cubit
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller!,
      shrinkWrap: true,
      itemCount: 48 + 1,
      itemBuilder: (context, int index) => index < 48
          ? Holding(sats: pow(index, index ~/ 4.2) as int)
          : SizedBox(height: screen.navbar.height));
}

class Holding extends StatelessWidget {
  final int sats;
  const Holding({super.key, required this.sats});

  String shorten(int sats) {
    if (sats < 1000) {
      return '$sats';
    }
    if (sats < 1000000) {
      return '${(sats / 1000).toStringAsFixed(0)}k';
    }
    if (sats < 1000000000) {
      return '${(sats / 1000000).toStringAsFixed(0)}m';
    }
    if (sats < 1000000000000) {
      return '${(sats / 1000000000).toStringAsFixed(0)}b';
    }
    if (sats < 1000000000000000) {
      return '${(sats / 1000000000000).toStringAsFixed(0)}t';
    }
    if (sats < 1000000000000000000) {
      return '${(sats / 1000000000000000).toStringAsFixed(0)}q';
    }
    return '∞';
  }

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: maestro.activateTransactions,
        leading: const SimpleIdenticon(),
        //Icon(Icons.circle,
        //    color: AppColors.success, size: screen.iconLarge),
        title: SizedBox(
            width: screen.width -
                (screen.iconMedium +
                    screen.iconMedium +
                    screen.iconLarge +
                    24 +
                    24),
            //color: Colors.grey,
            child: Text('Coin',
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.black87))),
        trailing: SizedBox(
            width: screen.iconMedium + screen.iconMedium,
            //color: Colors.grey,
            child: Text(shorten(sats),
                textAlign: TextAlign.right,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: AppColors.black60))),
      );
}

class SimpleIdenticon extends StatelessWidget {
  final Color? color;
  final String? letter;
  const SimpleIdenticon({super.key, this.letter, this.color});

  @override
  Widget build(BuildContext context) {
    final chosenColor = color ??
        AppColors.identicons[Random().nextInt(AppColors.identicons.length)];
    final chosenLetter =
        letter ?? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Random().nextInt(26)];

    return Container(
      width: screen.iconLarge,
      height: screen.iconLarge,
      decoration: BoxDecoration(
        color: chosenColor,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.bottomCenter,
      child: Text(chosenLetter, style: AppText.identicon),
    );
  }
}
