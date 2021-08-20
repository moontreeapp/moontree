import 'package:ordered_set/ordered_set.dart';

import 'index.dart';

int defaultCompare<Item>(Item item1, Item item2) {
  return item1.toString().compareTo(item2.toString());
}

class IndexMultiple<Key extends Object, Record extends Object>
    extends Index<Key, Record> {
  final Map<Key, OrderedSet<Record>> _data = {};
  late final Compare<Record> compare;

  IndexMultiple(GetKey<Key, Record> getKey, [Compare? compare])
      : compare = compare ?? defaultCompare,
        super(getKey);

  // Returns the number of keys in this index.
  @override
  Iterable<Key> get keys => _data.keys;

  /// Returns the total number of records in this index (may be more than
  /// the size of `keys` because each key can store multiple records)
  @override
  Iterable<Record> get values sync* {
    for (var list in _data.values) {
      for (var item in list) {
        yield item;
      }
    }
  }

  @override
  Record? getOne(Key key) => getAll(key).first;

  /// Retrieve all values associated with the key, in order.
  OrderedSet<Record> getAll(Key key) => _data[key] ?? OrderedSet<Record>();

  /// Return the size (length of the set) of a named index
  int size(Key key) => _data[key]!.length;

  /// Add a row to the indexed values; if the row has already been added, this
  /// is a no-op.
  @override
  void add(Record row) {
    var key = getKey(row);
    OrderedSet<Record> set;
    if (!_data.containsKey(key)) {
      set = _data[key] = OrderedSet<Record>(compare);
    } else {
      set = _data[key]!;
    }
    set.add(row);
  }

  /// Remove a record from the index
  @override
  bool remove(Record row) {
    var key = getKey(row);
    var removed = false;
    if (_data.containsKey(key)) {
      _data[key]!.remove(row);
      removed = true;
    }

    // If row is the last in the set, remove the set itself
    if (_data[key] != null && _data[key]!.isEmpty) _data.remove(key);

    return removed;
  }
}
