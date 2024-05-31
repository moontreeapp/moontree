import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/wallet/cubit.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/presentation/theme/theme.dart';
import 'package:magic/presentation/widgets/assets/amounts.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:magic/services/services.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key});

  @override
  Widget build(BuildContext context) => BlocBuilder<WalletCubit, WalletState>(
      buildWhen: (previous, current) => previous.holdings != current.holdings,
      builder: (BuildContext context, WalletState state) =>
          BlocBuilder<MenuCubit, MenuState>(
              buildWhen: (previous, current) => previous.mode != current.mode,
              builder: (BuildContext context, MenuState state) =>
                  ListView.builder(
                      controller: cubits.pane.state.scroller!,
                      shrinkWrap: true,
                      itemCount: cubits.wallet.state.holdings.length,
                      itemBuilder: (context, int index) => cubits
                              .wallet.state.holdings[index].symbol
                              .endsWith('!')
                          ? const SizedBox(height: 0)
                          : HoldingItem(
                              holding: cubits.wallet.state.holdings[index]))));
}

class HoldingItem extends StatelessWidget {
  final Holding holding;
  const HoldingItem({super.key, required this.holding});

  @override
  Widget build(BuildContext context) => ListTile(
        /// this functionality is replaced by the WalletStack
        //onTap: () => cubits.pane.state.height == screen.pane.minHeight
        //    ? cubits.pane.snapTo(screen.pane.midHeight)
        //    : maestro.activateHistory(),
        onTap: () => maestro.activateHistory(holding),
        leading: holding.isRoot
            ? CurrencyIdenticon(holding: holding)
            : SimpleIdenticon(letter: holding.assetPathChild[0]),
        title: SizedBox(
            width: screen.width -
                (screen.iconMedium +
                    screen.iconMedium +
                    screen.iconLarge +
                    24 +
                    24),
            //color: Colors.grey,
            //child: HighlightedNameView(
            //  holding: holding,
            //  parentsStyle: AppText.parentsAssetNameDark,
            //  childStyle: AppText.childAssetNameDark,
            //)),

            child: Text(
                holding.isRoot
                    ? holding.blockchain!.chain.title
                    : holding.assetPathChild,
                style: Theme.of(context)
                    .textTheme
                    .body1
                    .copyWith(color: Colors.black87))),
        subtitle: SimpleCoinSplitView(coin: holding.coin, incoming: null),
        trailing: FiatView(fiat: holding.coin.toFiat(holding.rate)),
      );
}

class CurrencyIdenticon extends StatelessWidget {
  final Holding holding;
  final double? height;
  final double? width;
  const CurrencyIdenticon({
    super.key,
    required this.holding,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? screen.iconLarge,
      height: height ?? screen.iconLarge,
      alignment: Alignment.bottomCenter,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        //borderRadius: BorderRadius.circular(100),
      ),
      child: Image.asset(holding.blockchain!.logo),
    );
  }
}

class SimpleIdenticon extends StatelessWidget {
  final Color? color;
  final String? letter;
  final double? height;
  final double? width;
  final TextStyle? style;
  final bool? admin;
  const SimpleIdenticon({
    super.key,
    this.letter,
    this.color,
    this.width,
    this.height,
    this.style,
    this.admin,
  });

  @override
  Widget build(BuildContext context) {
    final chosenLetter =
        letter ?? 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'[Random().nextInt(26)];
    final chosenColor = color ??
        //AppColors.identicons[Random().nextInt(AppColors.identicons.length)];
        AppColors.identicons[
            'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890'
                    .indexOf(letter!) %
                AppColors.identicons.length];

    final identicon = Container(
      width: width ?? screen.iconLarge,
      height: height ?? screen.iconLarge,
      alignment: Alignment.bottomCenter,
      decoration: BoxDecoration(
        color: chosenColor,
        shape: BoxShape.circle,
        //border: Border.all(
        //  //color: AppColors.primary, // Replace with your desired border color
        //  width: 2.0,
        //),
      ),
      child: Text(chosenLetter, style: style ?? AppText.identiconLarge),
    );
    if (admin == true) {
      return Stack(
        children: <Widget>[
          identicon,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: screen.iconSmall,
              height: screen.iconSmall,
              alignment: Alignment.bottomCenter,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary,
              ),
              child: const Icon(Icons.star, color: Colors.white, size: 16),
            ),
          ),
        ],
      );
    }
    return identicon;
  }
}

extension CurrencyLogo on Blockchain {
  String get logo {
    switch (this) {
      case Blockchain.ravencoinMain:
        return LogoIcons.rvn;
      case Blockchain.ravencoinTest:
        return LogoIcons.rvn;
      case Blockchain.evrmoreMain:
        return LogoIcons.evr;
      case Blockchain.evrmoreTest:
        return LogoIcons.evr;
      default:
        return LogoIcons.evr;
    }
  }
}
