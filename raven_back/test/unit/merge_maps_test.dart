import 'package:collection/collection.dart';
import 'package:test/test.dart';

void main() {
  group('mergeMaps', () {
    test("map's values override defaults", () {
      var map = {'one': 1, 'two': null};
      var defaults = {'two': 2, 'three': 3};
      var merged = mergeMaps(map, defaults,
          value: (mapVals, defaultVals) => (mapVals ?? defaultVals));
      expect(merged, {'one': 1, 'two': 2, 'three': 3});
    });
  });
}
