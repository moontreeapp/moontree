import 'package:ordered_set/ordered_set.dart';

typedef GetKey<B> = B Function(dynamic);
typedef Compare<B> = int Function(B, B);

int defaultCompare<B>(B b1, B b2) {
  return b1.hashCode.compareTo(b2.hashCode);
}

class Index<Key, Model> {
  final Map<Key, OrderedSet<Model>> values = {};
  final GetKey<Key> getKey;
  late final Compare<Model> compare;

  Index(this.getKey, Iterable rows, [Compare? compare])
      : compare = compare ?? defaultCompare {
    for (var row in rows) {
      add(row);
    }
  }

  /// If this is a unique index, retrieve the one and only value for the key;
  /// If this is not a unique index, retrieve the first value associated with the key.
  Model? get(Key key) => values[key]?.first;

  /// Retrieve all values associated with the key, in order.
  OrderedSet<Model>? getAll(Key key) => values[key];

  /// Return the size (length of the set) of a named index
  int size(Key key) => values[key]!.length;

  /// Add a row to the indexed values; if the row has already been added, this
  /// is a no-op.
  void add(Model row) {
    var key = getKey(row);
    OrderedSet<Model> set;
    if (!values.containsKey(key)) {
      set = values[key] = OrderedSet<Model>(compare);
    } else {
      set = values[key]!;
    }
    set.add(row);
  }

  /// Update a row by replacing an old row with the new row.
  void update(Model newRow, Model oldRow) {
    var oldKey = getKey(oldRow);
    var newKey = getKey(newRow);
    if (newKey != oldKey || newRow.hashCode != oldRow.hashCode) {
      remove(oldRow, oldKey);
    }
    values[newKey]!.add(newRow);
  }

  /// Remove a row from the set of indexed values; if the row is the last in
  /// the set, remove the set itself.
  bool remove(Model row, [Key? key]) {
    key ??= getKey(row);
    var removed = false;
    if (values.containsKey(key)) {
      values[key]!.remove(row);
      removed = true;
    }
    if (values[key] != null && values[key]!.isEmpty) values.remove(key);
    return removed;
  }
}
