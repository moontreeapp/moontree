import 'package:flutter_test/flutter_test.dart';
import 'package:client_back/records/types/net.dart';
import 'package:client_front/domain/utils/address.dart';

void main() {
  test('test verification of base58 addresses', () {
    const String mainAddress = 'RVNGuyEE9nBUt6aQbwVAhvEjcw7D3c6p2K';
    const String mTestAddress = 'mVNGuyEE9nBUt6aQbwVAhvEjcw7D3c6p2K';
    const String nTestAddress = 'nVNGuyEE9nBUt6aQbwVAhvEjcw7D3c6p2K';
    expect(rvnCondition(mainAddress, net: Net.main), true);
    expect(rvnCondition(mainAddress, net: Net.test), false);
    expect(rvnCondition('9$mainAddress', net: Net.main), false);
    expect(rvnCondition('${mainAddress}a', net: Net.main), false);
    expect(rvnCondition(mTestAddress, net: Net.test), true);
    expect(rvnCondition(nTestAddress, net: Net.test), true);
    expect(rvnCondition(mTestAddress, net: Net.main), false);
    expect(rvnCondition(nTestAddress, net: Net.main), false);
    expect(rvnCondition('9$mTestAddress', net: Net.test), false);
    expect(rvnCondition('9$nTestAddress', net: Net.test), false);
    expect(rvnCondition('${mTestAddress}a', net: Net.test), false);
    expect(rvnCondition('${nTestAddress}a', net: Net.test), false);
    expect(rvnCondition(mTestAddress.substring(0, 15), net: Net.test), false);
  });

  test('test verification of asset names', () {
    expect(assetCondition('RV'), false);
    expect(assetCondition('RVN'), false);
    expect(assetCondition('RAVEN'), false);
    expect(assetCondition('RAVENCOIN'), false);
    expect(assetCondition('RAVENCOIN5000'), true);
    expect(assetCondition('RavenCoin5000'), false);
    expect(assetCondition('THIS_IS_THIRTY_XXXX_CHARS_LONG'), true);
    expect(assetCondition('THIS_IS_THIRTY_ONE_X_CHARS_LONG'), false);
    expect(assetCondition('THIS_IS_THIRTY_ONEX_CHARS_LONG!'), true);
    expect(assetCondition('THIS_IS_NOT_THIRTY_CHARS_LONG'), true);
    expect(assetCondition('THIS_IS_NOT_THIRTY_CHARS_LONG!'), true);
    expect(assetCondition('THIS_ONE_is_lower_case'), false);
    expect(assetCondition('THIS_ONE HAS SPACES'), false);
    expect(assetCondition('THIS_ONE.HAS.PERIODS'), true);
    expect(assetCondition('THIS_ONE.HAS.DOUBLE..PERIODS'), false);
    expect(assetCondition('THIS_ONE.HAS._DOUDLBE_PUNC'), false);
    expect(assetCondition('THIS_ONE.HAS_.DOUDLBE_PUNC'), false);
    expect(assetCondition('THIS_ONE.HAS__DOUDLBE_PUNC'), false);
    expect(assetCondition('THIS_ONE_ENDS_WITH_PERIOD.'), false);
    expect(assetCondition('THIS_ONE_ENDS_WITH_'), false);
    expect(assetCondition('.THIS_ONE_STARTS_WITH_PERIOD'), false);
    expect(assetCondition('_THIS_ONE_STARTS_WITH_US'), false);
    expect(assetCondition('THIS_CONTAIN_&_BAD_PUNC'), false);
    expect(assetCondition('FANFT/RAVENHEAD24#PaintedRVN5'), false);
    expect(assetCondition(''), false);
  });
}
