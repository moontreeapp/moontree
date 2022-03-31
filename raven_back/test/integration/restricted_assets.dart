import 'dart:io';

import 'package:raven_back/services/wallet.dart';
import 'package:raven_back/records/address.dart' as address;
import 'package:raven_back/services/wallet/import.dart';
import 'package:raven_back/services/wallet/leader.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';
import 'package:test/test.dart';

import 'package:raven_electrum/raven_electrum.dart';
import 'package:raven_back/raven_back.dart';
import '../../lib/services/transaction_maker.dart';
import '../fixtures/fixtures_live.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() async {
  await useLiveSources();

  final wallet = res.wallets.primaryIndex.values.first;
  sleep(Duration(minutes: 1));

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
