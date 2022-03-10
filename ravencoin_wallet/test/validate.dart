import 'package:ravencoin_wallet/src/validate.dart';
import 'package:test/test.dart';
import 'package:bs58/bs58.dart';

import '../lib/src/assets.dart';
import '../lib/src/address.dart';

import '../lib/src/models/networks.dart';

main() {
  group('name', () {
    test('invalidate bad entire asset name', () {
      expect(isAssetNameGood(r'a'), false);
      expect(isAssetNameGood(r'abc'), false);
      expect(
          isAssetNameGood(
              r'abcefghijklmnopqrstuvwxyzabcefghijklmnopqrstuvwxyz'),
          false);
      expect(isAssetNameGood(r'RVN'), false);
      expect(isAssetNameGood(r'ABC/'), false);
      expect(isAssetNameGood(r'$ABC/'), false);
      expect(isAssetNameGood(r'$ABC/abc'), false);
      expect(isAssetNameGood(r'$ABC/ABC'), false);
      expect(isAssetNameGood(r'#ABC/ABC'), false);
      expect(isAssetNameGood(r'ABC!/ABC'), false);
      expect(isAssetNameGood(r'#ABC/#ABC#ABC'), false);
      expect(isAssetNameGood(r'#ABC/~ABC'), false);
      expect(isAssetNameGood(r'ABC._'), false);
      expect(isAssetNameGood(r'ABC._ABC'), false);
    });
    test('validate good entire asset name', () {
      expect(isAssetNameGood(r'123!'), true);
      expect(isAssetNameGood(r'$123!'), true);
      expect(isAssetNameGood(r'$123'), true);
      expect(isAssetNameGood(r'#123'), true);
      expect(isAssetNameGood(r'123'), true);
      expect(isAssetNameGood(r'ABC'), true);
      expect(isAssetNameGood(r'$ABC'), true);
      expect(isAssetNameGood(r'ABC!'), true);
      expect(isAssetNameGood(r'#ABC'), true);
      expect(isAssetNameGood(r'$ABC!'), true);
      expect(isAssetNameGood(r'ABC/ABC'), true);
      expect(isAssetNameGood(r'ABC/ABC/ABC'), true);
      expect(isAssetNameGood(r'ABC/ABC!'), true);
      expect(isAssetNameGood(r'ABC/ABC/ABC!'), true);
      expect(isAssetNameGood(r'ABC/ABC/ABC~ABC'), true);
      expect(isAssetNameGood(r'ABC/ABC/ABC#ABC'), true);
      expect(isAssetNameGood(r'ABC/ABC#ABC'), true);
      expect(isAssetNameGood(r'ABC#ABC'), true);
      expect(isAssetNameGood(r'ABC/ABC~ABC'), true);
      expect(isAssetNameGood(r'ABC~ABC'), true);
      expect(isAssetNameGood(r'#ABC/#ABC'), true);
      expect(isAssetNameGood(r'#ABC/#ABC/#ABC'), true);
    });
  });
}
