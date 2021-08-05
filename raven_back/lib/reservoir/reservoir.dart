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
  final List<Model> data = [];
  late Stream<Change> changes;

  Reservoir(this.source, [toModel, toRecord]) {
    this.toModel = toModel ?? (record) => (Model as dynamic).fromRecord(record);
    this.toRecord = toRecord ?? (model) => (model as dynamic).toRecord();
    changes = source.watch(this);
  }

  UniqueIndex addPrimaryIndex(GetKey<Key, Model> getKey) {
    primaryIndex = UniqueIndex(getKey)..addAll(data);
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

  @override
  Iterator<Model> get iterator => data.iterator;

  void saveAll(List<Model> models) {
    for (var model in models) {
      save(model);
    }
  }

  void save(Model model) {
    var key = indices['_primary']!.getKey(model);
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
    var value = toModel(record);
    _addToIndices(key, value);
    data[key] = value;
    return Added(key, value);
  }

  void _addToIndices(key, Model value) {
    for (var index in indices.values) {
      index.add(value);
    }
  }

  Change updateRecord(key, Record record) {
    var model = toModel(record);
    _updateIndices(key, model);
    data[key] = model;
    return Updated(key, model);
  }

  void _updateIndices(key, Model value) {
    for (var index in indices.values) {
      index.add(value);
    }
  }

  Change removeRecord(key) {
    _removeFromIndices(data[key]!);
    data.remove(key);
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
