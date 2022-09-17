import 'package:ravencoin_back/records/types/node_exposure.dart';
import 'package:test/test.dart';
import 'package:ravencoin_back/utilities/derivation_path.dart';

void main() {
  test('derive', () {
    expect(getDerivationPath(0), "m/44'/175'/0'/0/0");
    expect(getDerivationPath(0, exposure: NodeExposure.External, mainnet: true),
        "m/44'/175'/0'/0/0");
    expect(getDerivationPath(0, exposure: NodeExposure.Internal, mainnet: true),
        "m/44'/175'/0'/1/0");
    expect(getDerivationPath(1, exposure: NodeExposure.Internal, mainnet: true),
        "m/44'/175'/0'/1/1");
  });
}
