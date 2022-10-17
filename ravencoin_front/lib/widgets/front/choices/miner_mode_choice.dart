import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

enum MinerModeChoices {
  on,
  off,
}

class MinerModeChoice extends StatefulWidget {
  final dynamic data;
  const MinerModeChoice({this.data}) : super();

  @override
  _MinerModeChoice createState() => _MinerModeChoice();
}

class _MinerModeChoice extends State<MinerModeChoice> {
  MinerModeChoices? minerChoice = MinerModeChoices.off;

  @override
  void initState() {
    super.initState();
    minerChoice = services.wallet.currentWallet.minerMode == true
        ? MinerModeChoices.on
        : MinerModeChoices.off;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Miner Mode', style: Theme.of(context).textTheme.bodyText1),
        Text(
          'In Miner Mode, full transaction histories are not downloaded. This makes syncing your wallets faster.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        RadioListTile<MinerModeChoices>(
          title: const Text('On'),
          value: MinerModeChoices.on,
          groupValue: minerChoice,
          onChanged: (MinerModeChoices? value) => setState(() {
            if (value != null) {
              minerChoice = value;
              if (value == MinerModeChoices.on) {
                services.download.queue.setMinerMode(true);
              } else {
                services.download.queue.setMinerMode(false);
              }
            }
          }),
        ),
        RadioListTile<MinerModeChoices>(
          title: const Text('Off'),
          value: MinerModeChoices.off,
          groupValue: minerChoice,
          onChanged: (MinerModeChoices? value) => setState(() {
            if (value != null) {
              minerChoice = value;
              if (value == MinerModeChoices.on) {
                services.download.queue.setMinerMode(true);
              } else {
                services.download.queue.setMinerMode(false);
              }
            }
          }),
        ),
      ],
    );
  }
}
