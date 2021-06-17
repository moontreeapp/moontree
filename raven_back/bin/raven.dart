import 'package:raven/account.dart';
import 'package:raven/raven_networks.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() {
  var seed = bip39.mnemonicToSeed(
      'smile build brain topple moon scrap area aim budget enjoy polar erosion');

  var account = Account(ravencoinTestnet, seed: seed);
  var node = account.node(0);

  print('address: ${node.wallet.address}');
  print('pubKey: ${node.wallet.pubKey}');
  print('wif: ${node.wallet.wif}');
}
