// dart test test/unit/extensions/list.dart
import 'package:test/test.dart';
import 'package:raven_back/extensions/iterable.dart';

void main() {
  group('List Extensions', () {
    test('sum', () {
      expect([0].sum(), 0);
      expect([1].sum(), 1);
      expect([1, 2, 3].sum(), 6);
      expect([].sum(), 0);
      expect([null].sum(), 0);
      expect(['a'].sum(), 0);
      expect([1, 'a'].sum(), 1);
      expect([1.1, 'a'].sum(), 1.1);
    });
    test('sumInt', () {
      expect([0].sumInt(), 0);
      expect([1].sumInt(), 1);
      expect([1, 2, 3].sumInt(), 6);
      expect([].sumInt(), 0);
      expect([null].sumInt(), 0);
      expect(['a'].sumInt(), 0);
      expect([1, 'a'].sumInt(), 1);
      expect([1.1, 'a'].sumInt(), 1);
      expect([1.5, 'a'].sumInt(), 1);
      expect([1.9, 'a'].sumInt(), 1);
      expect([1.9, 'a'].sumInt(truncate: false), 2);
    });
    test('sumDouble', () {
      expect([0].sumDouble(), 0.0);
      expect([1].sumDouble(), 1.0);
      expect([1, 2, 3].sumDouble(), 6.0);
      expect([].sumDouble(), 0.0);
      expect([null].sumDouble(), 0.0);
      expect(['a'].sumDouble(), 0.0);
      expect([1, 'a'].sumDouble(), 1.0);
      expect([1.1, 'a'].sumDouble(), 1.1);
      expect([1.5, 'a'].sumDouble(), 1.5);
      expect([1.9, 'a'].sumDouble(), 1.9);
    });
  });
}
