import 'package:ordered_set/ordered_set.dart';

import 'index.dart';
import 'key.dart';

class IndexMultiple<K extends Key<Record>, Record> extends Index<K, Record> {
  final Map<String, OrderedSet<Record>> _data = {};
  late final Compare<Record> compare;

  IndexMultiple(K keyType, [Compare? compare])
      : compare = compare ?? defaultCompare,
        super(keyType);

  @override
  Iterable<String> get keys => _data.keys;

  /// Returns all records in this index (may be more than the size of `keys`
  /// because each key can store multiple records)
  @override
  Iterable<Record> get values sync* {
    for (var list in _data.values) {
      for (var item in list) {
        yield item;
      }
    }
  }

  @override
  void clear() {
    _data.clear();
  }

  /// Add a row to the indexed values; if the row has already been added, this
  /// is a no-op.
  @override
  void add(Record record) {
    var key = keyType.getKey(record);
    OrderedSet<Record> set;
    if (!_data.containsKey(key)) {
      set = _data[key] = OrderedSet<Record>(compare);
    } else {
      set = _data[key]!;
    }
    set.add(record);
  }

  @override
  List<Record> getByKeyStr(String key) {
    return _data[key]?.toList() ?? [];
  }

  /// Remove a record from the index
  @override
  bool remove(Record record) {
    var key = keyType.getKey(record);
    var removed = false;
    if (_data.containsKey(key)) {
      _data[key]!.remove(record);
      removed = true;
    }

    // If row is the last in the set, remove the set itself
    if (_data[key] != null && _data[key]!.isEmpty) _data.remove(key);

    return removed;
  }

  /// Return the size (length of the set) of a named index
  int? size(K key) => _data[key]?.length;
}

int defaultCompare<Item>(Item item1, Item item2) {
  return item1.toString().compareTo(item2.toString());
}
