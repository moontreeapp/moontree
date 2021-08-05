import 'package:ordered_set/ordered_set.dart';

typedef GetKey<Key, Model> = Key Function(Model);
typedef Compare<A> = int Function(A, A);

int defaultCompare<Item>(Item item1, Item item2) {
  return item1.toString().compareTo(item2.toString());
}

abstract class Index<Key, Model> {
  final GetKey<Key, Model> getKey;

  Index(this.getKey);

  Iterable<Key> get keys;
  Iterable<Model> get values;

  void add(Model model);
  void addAll(Iterable<Model> models) => models.forEach((model) => add(model));
  Model? get(Key key);
  bool has(Key key) => get(key) != null;
  bool remove(Model model);
}

class UniqueIndex<Key, Model> extends Index<Key, Model> {
  final Map<Key, Model> _data = {};

  UniqueIndex(getKey) : super(getKey);

  @override
  Iterable<Key> get keys => _data.keys;

  @override
  Iterable<Model> get values => _data.values;

  @override
  void add(Model model) => _data[getKey(model)] = model;

  @override
  Model? get(Key key) => _data[key];

  @override
  bool remove(Model model) {
    var key = getKey(model);
    if (_data.containsKey(key)) {
      _data.remove(key);
      return true;
    } else {
      return false;
    }
  }
}

class MultipleIndex<Key, Model> extends Index<Key, Model> {
  final Map<Key, OrderedSet<Model>> _data = {};
  late final Compare<Model> compare;

  MultipleIndex(getKey, [Compare? compare])
      : compare = compare ?? defaultCompare,
        super(getKey);

  // Returns the number of keys in this index.
  @override
  Iterable<Key> get keys => _data.keys;

  /// Returns the total number of models in this index (may be more than
  /// the size of `keys` because each key can store multiple models)
  @override
  Iterable<Model> get values sync* {
    for (var list in _data.values) {
      for (var item in list) {
        yield item;
      }
    }
  }

  @override
  Model? get(Key key) => getAll(key).first;

  /// Retrieve all values associated with the key, in order.
  OrderedSet<Model> getAll(Key key) => _data[key] ?? OrderedSet<Model>();

  /// Return the size (length of the set) of a named index
  int size(Key key) => _data[key]!.length;

  /// Add a row to the indexed values; if the row has already been added, this
  /// is a no-op.
  @override
  void add(Model row) {
    var key = getKey(row);
    OrderedSet<Model> set;
    if (!_data.containsKey(key)) {
      set = _data[key] = OrderedSet<Model>(compare);
    } else {
      set = _data[key]!;
    }
    set.add(row);
  }

  /// Remove a model from the index
  @override
  bool remove(Model row) {
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
