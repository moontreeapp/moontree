import 'dart:io';

import 'package:test/test.dart';

import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import '../fixtures/fixtures_live.dart';

void main() async {
  await useLiveSources();

  final wallet = res.wallets.primaryIndex.values.first;
  sleep(Duration(seconds: 10));

  print(wallet);
  print(wallet.addresses);
  print(services.balance.collectUTXOs(wallet, amount: 1));

  test('query info', () async {
    var client =
        // RavenElectrumClient(await connect('testnet.rvn.rocks'));
        RavenElectrumClient(await connect('rvn4lyfe.com', port: 50003));
    await client.serverVersion(
        clientName: 'MOONTREE TEST', protocolVersion: '1.9');
  });

  //deleteDatabase();
}
