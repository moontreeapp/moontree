// dart --no-sound-null-safety run bin/raven.dart
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/account.dart';
import 'package:raven/electrum_client.dart';
import 'package:raven/electrum_client/connect.dart';
import 'package:raven/raven_networks.dart';

void main() async {
  var seed = bip39.mnemonicToSeed(
      'smile build brain topple moon scrap area aim budget enjoy polar erosion');
  var account = Account(ravencoinTestnet, seed: seed);
  var node = account.node(0);
  var client = ElectrumClient(await connect('testnet.rvn.rocks'));
  var version = await client.serverVersion(protocolVersion: '1.8');
  print('Server Version: $version');
  print('address: ${node.wallet.address}');
  print('pubKey: ${node.wallet.pubKey}');
  print('wif: ${node.wallet.wif}');
  await client.close();
}
