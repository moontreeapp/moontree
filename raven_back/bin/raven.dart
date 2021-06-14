import 'package:raven/raven_network.dart';
import 'package:bip39/bip39.dart' as bip39;

void main() {
  var seed = bip39.mnemonicToSeed(
      'smile build brain topple moon scrap area aim budget enjoy polar erosion');

  var network = RavenNetwork(ravencoinTestnet);
  var hdWallet = network.getRavenWallet(seed).getHDWallet(0);

  print('address: ${hdWallet.address}');
  print('pubKey: ${hdWallet.pubKey}');
  print('wif: ${hdWallet.wif}');
}
