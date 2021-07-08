// dart --no-sound-null-safety run bin/raven.dart
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/account.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:raven/raven_networks.dart';
import 'package:raven/boxes.dart' as boxes;
import 'package:raven/accounts.dart' as accounts;

void main() async {
  var seed = bip39.mnemonicToSeed(
      'smile build brain topple moon scrap area aim budget enjoy polar erosion');
  // encrypt seed
  var account = Account(ravencoinTestnet, seed: seed);
  var node = account.node(0);
  var client = await RavenElectrumClient.connect('testnet.rvn.rocks');
  var version = await client.serverVersion(protocolVersion: '1.8');
  print('Server Version: $version');
  print('address: ${node.wallet.address}');
  print('pubKey: ${node.wallet.pubKey}');
  print('wif: ${node.wallet.wif}');
  await client.close();
  await boxes.Truth.instance.open();
  await accounts.Accounts.instance.load();
}
