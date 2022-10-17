import 'package:flutter/material.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

class MiningChoice extends StatelessWidget {
  const MiningChoice() : super();

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: SwtichChoice(
                      label: 'Miner Mode',
                      description:
                          'In Miner Mode, full transaction histories are not downloaded. This makes syncing your wallets faster.',
                      initial: services.wallet.currentWallet.minerMode,
                      onChanged: (value) =>
                          services.download.queue.setMinerMode(value),
                    )))),
      ]);
}
