// dart --no-sound-null-safety test test/account_test.dart

import 'dart:io';
import 'dart:async';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';

Future<String> getMnemonic() async {
  try {
    final file = File('.env');
    return await file.readAsString();
  } catch (e) {
    return 'smile build brain topple moon scrap area aim budget enjoy polar erosion';
  }
}

void main() {
  test('getBalance', () async {
    var pass = await getMnemonic();
    var seed = bip39.mnemonicToSeed(pass);
    var account = Account(ravencoinTestnet, seed: seed);
    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    await client.serverVersion(protocolVersion: '1.8');
    var balance = await account.getBalance(client);
    if (pass.startsWith('smile')) {
      expect(balance, 0.0);
    } else {
      expect((balance > 0), true);
    }
  });
}
