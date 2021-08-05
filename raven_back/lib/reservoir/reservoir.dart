import 'dart:collection';

import 'change.dart';
import 'index.dart';
import 'source.dart';

export 'hive_source.dart';

typedef Mapper<Record, Model> = Model Function(Record);

class Reservoir<Key, Record, Model> with IterableMixin<Model> {
  final Source<Key, Record, Model> source;
  late Mapper<Record, Model> toModel;
  late Mapper<Model, Record> toRecord;
  late UniqueIndex<Key, Model> primaryIndex;
  final Map<String, Index<Key, Model>> indices = {};
  late Stream<Change> changes;

  Reservoir(this.source, [toModel, toRecord]) {
    this.toModel = toModel ?? (record) => (Model as dynamic).fromRecord(record);
    this.toRecord = toRecord ?? (model) => (model as dynamic).toRecord();
    changes = source.watch(this);
  }

  Iterable<Model> get data => primaryIndex.values;

  UniqueIndex addPrimaryIndex(GetKey<Key, Model> getKey) {
    primaryIndex = UniqueIndex(getKey);
    return primaryIndex;
  }

  UniqueIndex addUniqueIndex(String name, GetKey<Key, Model> getKey) {
    if (!indices.containsKey(name)) {
      return indices[name] = UniqueIndex(getKey)..addAll(data);
    } else {
      throw ArgumentError('index $name already exists');
    }
  }

  MultipleIndex addMultipleIndex(String name, GetKey<Key, Model> getKey,
      [Compare? compare]) {
    if (!indices.containsKey(name)) {
      return indices[name] = MultipleIndex(getKey, compare)..addAll(data);
    } else {
      throw ArgumentError('index $name already exists');
    }
  }

  Index? removeIndex(String name) {
    return indices.remove(name);
  }

  Model? get(Key key) => primaryIndex.getOne(key);

  @override
  Iterator<Model> get iterator => data.iterator;

  void saveAll(List<Model> models) {
    for (var model in models) {
      save(model);
    }
  }

  void save(Model model) {
    var key = primaryIndex.getKey(model);
    // Save key to source, which will (reactively) notify this reservoir of the
    // new key and construct a new model, also updating any associated indices.
    source.save(key, toRecord(model));
  }

  void remove(Model model) {
    var key = primaryIndex.getKey(model);
    if (primaryIndex.has(key)) {
      // Remove key from source, which will (reactively) notify this reservoir
      // and then remove the key and any associated keys in indices.
      source.remove(key);
    } else {
      throw ArgumentError('record not found for $key');
    }
  }

  Change addRecord(key, Record record) {
    var model = toModel(record);
    _addToIndices(model);
    primaryIndex.add(model);
    return Added(key, model);
  }

  void _addToIndices(Model value) {
    for (var index in indices.values) {
      index.add(value);
    }
  }

  Change updateRecord(key, Record record) {
    var model = toModel(record);
    _updateIndices(key, model);
    primaryIndex.add(model);
    return Updated(key, model);
  }

  void _updateIndices(key, Model value) {
    for (var index in indices.values) {
      index.add(value);
    }
  }

  Change removeRecord(key) {
    _removeFromIndices(primaryIndex.getOne(key)!);
    primaryIndex.remove(key);
    return Removed(key);
  }

  void _removeFromIndices(Model model) {
    for (var index in indices.values) {
      index.remove(model);
    }
  }

  @override
  String toString() => 'Reservoir($source, '
      'size: ${data.length}, '
      'indices: ${indices.keys.toList().join(",")})';
}
