import 'dart:io';

import 'package:test/test.dart';

import 'package:ravencoin_electrum/ravencoin_electrum.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import '../fixtures/fixtures_live.dart';

void main() async {
  await useLiveSources();

  final wallet = pros.wallets.primaryIndex.values.first as LeaderWallet;
  sleep(Duration(seconds: 10));

  test('query info', () async {
    var client =
        // RavenElectrumClient(await connect('testnet.rvn.rocks'));
        RavenElectrumClient(await connect('rvn4lyfe.com', port: 50003));
    await client.serverVersion(
        clientName: 'MOONTREE TEST', protocolVersion: '1.9');
  });

  //deleteDatabase();
}
