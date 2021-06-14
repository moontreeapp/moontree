import 'package:raven/raven_network.dart';
import 'package:test/test.dart';

void main() {
  test('networks', () {
    expect(ravencoinMainnet.derivationBase, "m/44'/175'/0'");
    expect(ravencoinTestnet.derivationBase, "m/44'/175'/1'");
  });
}
