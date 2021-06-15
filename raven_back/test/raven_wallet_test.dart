import 'package:raven/raven_wallet.dart';
import 'package:test/test.dart';
import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/raven_network.dart';

final seed = bip39.mnemonicToSeed(
    'smile build brain topple moon scrap area aim budget enjoy polar erosion');

final network = RavenNetwork(ravencoinTestnet);

void main() {
  test('reverse', () {
    var sample = [1, 2, 3, 4];
    expect(reverse(sample), [4, 3, 2, 1]);
  });

  test('scriptHashFromAddress', () {
    var wallet = network.getRavenWallet(seed);
    var scriptHash = wallet.scriptHashFromAddress(0);
    expect(scriptHash,
        '45520ecd53be9412d82e904a12a8fe7aeb0251eea1eaf1be02cab9fb98d1fad7');
  });
}
