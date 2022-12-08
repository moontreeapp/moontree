import 'dart:math';

import 'package:moontree_utils/src/search.dart';
import 'package:test/test.dart';

void main() {
  group('Binary', () {
    test('test remove', () {
      final List list = [];
      for (int i = 0; i < 1000; i++) {
        list.add(i);
      }
      for (int i = 0; i < 1000; i++) {
        final List list1 = [];
        final List list2 = [];
        list.forEach((e) {
          list1.add(e);
          list2.add(e);
        });
        list2.remove(i);
        expect(
            binaryRemove(list: list1, comp: (a, b) => (a - b) as int, value: i),
            true);
        expect(list1, list2);
      }
      expect(
          binaryRemove(list: list, comp: (a, b) => (a - b) as int, value: 1001),
          false);
    });

    test('binary insert', () {
      for (int _ = 0; _ < 100; _++) {
        final List list = [];
        final Random rand = Random();
        final int Function(dynamic a, dynamic b) comp =
            (a, b) => (a - b) as int;
        for (int i = 0; i < 1000; i++) {
          list.add(rand.nextInt(1 << 31));
        }
        final List list1 = [];
        list.forEach((element) {
          binaryInsert(list: list1, value: element, comp: comp);
        });
        list.sort(comp);
        expect(list, list1);
      }
    });
  });
}
