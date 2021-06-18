import 'dart:io';
import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/electrum_client.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;

bool skipUnverified(X509Certificate certificate) {
  return true;
}

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);
void main() {
  test('electrum client', () async {
    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    var version = await client.serverVersion(protocolVersion: '1.8');
    expect(version.name, 'ElectrumX Ravencoin 1.8.1');
    expect(version.protocol, '1.8');
    var features = await client.features();
    expect(features['genesis_hash'],
        '000000ecfc5e6324a079542221d00e10362bdc894d56500c414060eea8a3ad5a');
    expect(features['hash_function'], 'sha256');
  });

  test('getBalance', () async {
    var seed = bip39.mnemonicToSeed(
        'smile build brain topple moon scrap area aim budget enjoy polar erosion');

    var account = Account(ravencoinTestnet, seed: seed);

    var client = ElectrumClient();
    await client.connect(host: 'testnet.rvn.rocks', port: 50002);
    await client.serverVersion(protocolVersion: '1.8');

    var node = account.node(4, exposure: NodeExposure.Internal);

    var balance = await client.getBalance(scriptHash: node.scriptHash);
    expect(balance['confirmed'], 5000000);
    expect(balance['unconfirmed'], 0);
  });
}
