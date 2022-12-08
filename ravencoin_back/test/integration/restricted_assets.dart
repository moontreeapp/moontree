import 'dart:io';

import 'package:test/test.dart';

import 'package:electrum_adapter/electrum_adapter.dart';
import '../fixtures/fixtures_live.dart';

void main() async {
  await useLiveSources();

  sleep(const Duration(seconds: 10));

  test('query info', () async {
    final RavenElectrumClient client =
        // RavenElectrumClient(await connect('testnet.rvn.rocks'));
        RavenElectrumClient(await connect('rvn4lyfe.com', port: 50003));
    await client.serverVersion(
        clientName: 'MOONTREE TEST', protocolVersion: '1.9');
  });

  //deleteDatabase();
}
