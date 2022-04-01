import 'package:test/test.dart';
import '../../../lib/utilities/utilities.dart';

void main() {
  group('Binary removal', () {
    test('test', () {
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
  });
}
