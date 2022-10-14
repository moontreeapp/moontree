// dart test test/unit/extensions/object.dart

import 'package:ravencoin_back/records/types/net.dart';
import 'package:test/test.dart';
import 'package:ravencoin_back/extensions/object.dart';

void main() {
  group('Object Extensions', () {
    test('enumString', () {
      expect(Net.main.name, 'Main');
    });
  });
}
