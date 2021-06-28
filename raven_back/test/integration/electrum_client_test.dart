import 'dart:io';
import 'package:raven/electrum_client/connect.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/env.dart' as env;
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client/electrum_client.dart';

bool skipUnverified(X509Certificate certificate) {
  return true;
}

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

void main() {
  test('electrum client', () async {
    var client = ElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.8');
    var features = await client.features();
    expect(features['genesis_hash'],
        '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');
    expect(features['hash_function'], 'sha256');
  });

  test('getBalance', () async {
    var phrase = await env.getMnemonic();
    var seed = bip39.mnemonicToSeed(phrase);
    var account = Account(ravencoinTestnet, seed: seed);
    var client = ElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.8');
    var node = account.node(3, exposure: NodeExposure.Internal);
    var balance = await client.getBalance(scriptHash: node.scriptHash);
    if (phrase.startsWith('smile')) {
      expect(balance.confirmed, 0);
      expect(balance.unconfirmed, 0);
    } else {
      expect((balance.confirmed > 0), true);
      expect(balance.unconfirmed, 0);
    }
  });

  test('getUTXOs', () async {
    var phrase = await env.getMnemonic();
    var seed = bip39.mnemonicToSeed(phrase);
    var account = Account(ravencoinTestnet, seed: seed);
    var client = ElectrumClient(await connect('testnet.rvn.rocks'));
    await client.serverVersion(protocolVersion: '1.8');
    var node = account.node(3, exposure: NodeExposure.Internal);
    var utxos = await client.getUTXOs(scriptHash: node.scriptHash);
    expect(utxos, [
      ScriptHashUnspent(
          txHash:
              '84ab4db04a5d32fc81025db3944e6534c4c201fcc93749da6d1e5ecf98355533',
          txPos: 1,
          height: 765913,
          value: 5000087912000)
    ]);
  });

  //test('Subscribe', () async {
  //  var phrase = await env.getMnemonic();
  //  var seed = bip39.mnemonicToSeed(phrase);
  //  var account = Account(ravencoinTestnet, seed: seed);
  //  var client = ElectrumClient();
  //  await client.connect(host: 'testnet.rvn.rocks', port: 50002);
  //  var node = account.node(3, exposure: NodeExposure.Internal);
  //  //var subscription = await client.subscribeTo(scriptHash: node.scriptHash);
  //  //print(subscription);  // null - shouldn't this setup a stream or something?
  //});
}
