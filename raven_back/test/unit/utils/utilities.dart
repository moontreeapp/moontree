import 'dart:math';

import 'package:raven_back/utilities/search.dart';
import 'package:test/test.dart';
import '../../../lib/utilities/utilities.dart';

void main() {
  group('Binary', () {
    test('test remove', () {
      final list = [];
      for (var i = 0; i < 1000; i++) {
        list.add(i);
      }
      for (var i = 0; i < 1000; i++) {
        final list1 = [];
        final list2 = [];
        list.forEach((e) {
          list1.add(e);
          list2.add(e);
        });
        list2.remove(i);
        expect(utils.binaryRemove(list: list1, comp: (a, b) => a - b, value: i),
            true);
        expect(list1, list2);
      }
      expect(utils.binaryRemove(list: list, comp: (a, b) => a - b, value: 1001),
          false);
    });

    test('binary insert', () {
      for (var _ = 0; _ < 100; _++) {
        final list = [];
        final rand = Random();
        final comp = (a, b) => (a - b) as int;
        for (var i = 0; i < 1000; i++) {
          list.add(rand.nextInt(1 << 31));
        }
        final list1 = [];
        list.forEach((element) {
          binaryInsert(list: list1, value: element, comp: comp);
        });
        list.sort(comp);
        expect(list, list1);
      }
    });
  });
}
