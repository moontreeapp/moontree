import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

import 'package:raven/subjects/index.dart';

class TestRow with EquatableMixin {
  final int id;
  final String name;
  TestRow(this.id, this.name);

  @override
  List<Object> get props => [id];
}

void main() {
  group('Index', () {
    var rows = [TestRow(1, 'apple'), TestRow(2, 'apple'), TestRow(3, 'orange')];
    test('default sort order', () {
      var index = Index((row) => row.name, rows);
      expect(index.values['apple']?.toList(), [rows[1], rows[0]]);
      expect(index.values['orange']?.toList(), [rows[2]]);
    });

    test('explicit sort order', () {
      var index =
          Index((row) => row.name, rows, (r1, r2) => r1.id.compareTo(r2.id));
      expect(index.values['apple']?.toList(), [rows[0], rows[1]]);
      expect(index.values['orange']?.toList(), [rows[2]]);
    });

    test('remove', () {
      var index =
          Index((row) => row.name, rows, (r1, r2) => r1.id.compareTo(r2.id));
      expect(index.values['apple']?.toList(), [rows[0], rows[1]]);
      expect(index.values['orange']?.toList(), [rows[2]]);

      index.remove(rows[0]);
      expect(index.values['apple']?.toList(), [rows[1]]);
      expect(index.values['orange']?.toList(), [rows[2]]);

      index.remove(rows[1]);
      expect(index.values['apple'], null);
      expect(index.values['orange']?.toList(), [rows[2]]);
    });

    test('get', () {
      var index =
          Index((row) => row.name, rows, (r1, r2) => r1.id.compareTo(r2.id));
      expect(index.getAll('apple')?.toList(), [rows[0], rows[1]]);
    });
  });
}
