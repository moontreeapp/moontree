import 'package:equatable/equatable.dart';
import 'package:test/test.dart';

import 'package:raven/reservoir/index.dart';

class TestRow with EquatableMixin {
  final int id;
  final String name;
  TestRow(this.id, this.name);

  @override
  List<Object> get props => [id];
}

void main() {
  group('MultipleIndex', () {
    var rows = [TestRow(1, 'apple'), TestRow(2, 'apple'), TestRow(3, 'orange')];
    test('default sort order', () {
      var index = MultipleIndex((row) => row.name);
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[0], rows[1]]);
      expect(index.getAll('orange').toList(), [rows[2]]);
    });

    test('explicit sort order', () {
      var index =
          MultipleIndex((row) => row.name, (r1, r2) => r2.id.compareTo(r1.id));
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[1], rows[0]]);
      expect(index.getAll('orange').toList(), [rows[2]]);
    });

    test('remove', () {
      var index =
          MultipleIndex((row) => row.name, (r1, r2) => r1.id.compareTo(r2.id));
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
      var index =
          MultipleIndex((row) => row.name, (r1, r2) => r1.id.compareTo(r2.id));
      index.addAll(rows);
      expect(index.getAll('apple').toList(), [rows[0], rows[1]]);
    });
  });
}
