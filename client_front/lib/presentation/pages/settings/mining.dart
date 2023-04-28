import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/front/choices/switch_choice.dart';

class MiningSetting extends StatelessWidget {
  const MiningSetting({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SwtichChoice(
          label: 'Mine to Wallet',
          //description:
          //    'In Miner Mode, full transaction histories are not downloaded. This makes syncing your wallets faster.',
          initial: services.wallet.currentWallet.minerMode,
          onChanged: (bool value) => services.wallet.setMinerMode(value),
        )
      ],
    );
  }
}
