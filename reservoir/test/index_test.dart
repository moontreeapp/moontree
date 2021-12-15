import 'package:test/test.dart';
import 'package:reservoir/reservoir.dart';
import 'helpers/simple_record.dart';

void main() {
  group('IndexMultiple', () {
    var rows = [
      SimpleRecord('1', 'apple'),
      SimpleRecord('2', 'apple'),
      SimpleRecord('3', 'orange')
    ];

    test('default sort order', () {
      var index = IndexMultiple<ValueKey, SimpleRecord>(ValueKey());
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[0], rows[1]]);
      expect(index.getAll('orange').toList(), [rows[2]]);
    });

    test('explicit sort order', () {
      var index = IndexMultiple<ValueKey, SimpleRecord>(
          ValueKey(), (r1, r2) => r2.key.compareTo(r1.key));
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[1], rows[0]]);
      expect(index.getAll('orange').toList(), [rows[2]]);
    });

    test('remove', () {
      var index = IndexMultiple<ValueKey, SimpleRecord>(
          ValueKey(), (r1, r2) => r1.key.compareTo(r2.key));
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[0], rows[1]]);
      expect(index.getAll('orange').toList(), [rows[2]]);

      index.remove(rows[0]);
      expect(index.getAll('apple').toList(), [rows[1]]);
      expect(index.getAll('orange').toList(), [rows[2]]);

      index.remove(rows[1]);
      expect(index.getAll('apple').toList(), []);
      expect(index.getAll('orange').toList(), [rows[2]]);
    });

    test('get', () {
      var index = IndexMultiple<ValueKey, SimpleRecord>(
          ValueKey(), (r1, r2) => r1.key.compareTo(r2.key));
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[0], rows[1]]);
    });
  });
}
