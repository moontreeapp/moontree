import 'package:ravencoin_back/records/types/net.dart';
import 'package:ravencoin_back/records/types/node_exposure.dart';
import 'package:test/test.dart';
import 'package:ravencoin_back/utilities/derivation_path.dart';

void main() {
  test('derive', () {
    expect(getDerivationPath(index: 0), "m/44'/175'/0'/0/0");
    expect(
        getDerivationPath(
            index: 0, exposure: NodeExposure.external, net: Net.main),
        "m/44'/175'/0'/0/0");
    expect(
        getDerivationPath(
            index: 0, exposure: NodeExposure.internal, net: Net.main),
        "m/44'/175'/0'/1/0");
    expect(
        getDerivationPath(
            index: 1, exposure: NodeExposure.internal, net: Net.main),
        "m/44'/175'/0'/1/1");
  });
}
