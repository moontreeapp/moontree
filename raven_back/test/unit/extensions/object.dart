// dart test test/unit/extensions/object.dart

import 'package:raven_back/records/net.dart';
import 'package:test/test.dart';
import 'package:raven_back/extensions/object.dart';

void main() {
  group('Object Extensions', () {
    test('enumString', () {
      expect(Net.Main.enumString, 'Main');
    });
  });
}
