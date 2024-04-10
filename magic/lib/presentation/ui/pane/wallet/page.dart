import 'dart:math';
import 'package:flutter/material.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/services/services.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override // TODO: get from cubit
  Widget build(BuildContext context) => ListView.builder(
      controller: cubits.pane.state.scroller!,
      shrinkWrap: true,
      itemCount: cubits.wallet.state.assets.length + 1,
      itemBuilder: (context, int index) =>
          index < cubits.wallet.state.assets.length
              ? HoldingItem(asset: cubits.wallet.state.assets[index])
              : SizedBox(height: screen.navbar.height));
}

class HoldingItem extends StatelessWidget {
  final Holding asset;
  const HoldingItem({super.key, required this.asset});

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => cubits.pane.state.height == screen.pane.minHeight
            ? cubits.pane.snapTo(screen.pane.midHeight)
            : maestro.activateTransactions(),
        leading: const SimpleIdenticon(),
        title: SizedBox(
            width: screen.width -
                (screen.iconMedium +
                    screen.iconMedium +
                    screen.iconLarge +
                    24 +
                    24),
            //color: Colors.grey,
            child: Text(asset.isRoot ? asset.name : asset.symbol,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.black87))),
        subtitle: Text(asset.coin.simplified(),
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: AppColors.black60)),
        trailing: Text(asset.coin.toFiat(1).simplified(),
            textAlign: TextAlign.right,
            style: Theme.of(context)
                .textTheme
                .body1
                .copyWith(color: AppColors.black60)),
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
