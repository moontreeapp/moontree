import 'dart:async';
import 'dart:collection';

import 'change.dart';
import 'index.dart';
import 'source.dart';

export 'hive_source.dart';

class Reservoir<Key, Record> with IterableMixin<Record> {
  final Source<Key, Record> source;
  late UniqueIndex<Key, Record> primaryIndex;
  final Map<String, Index<Key, Record>> indices = {};
  late Stream<Change> changes;

  Reservoir(this.source) {
    changes = source.watch(this);
  }

  Iterable<Record> get data => primaryIndex.values;

  UniqueIndex<Key, Record> addPrimaryIndex(GetKey<Key, Record> getKey) {
    primaryIndex = UniqueIndex(getKey);
    return primaryIndex;
  }

  UniqueIndex<Key, Record> addUniqueIndex(
      String name, GetKey<Key, Record> getKey) {
    if (!indices.containsKey(name)) {
      return indices[name] = UniqueIndex(getKey)..addAll(data);
    } else {
      throw ArgumentError('index $name already exists');
    }
  }

  MultipleIndex<Key, Record> addMultipleIndex(
      String name, GetKey<Key, Record> getKey,
      [Compare? compare]) {
    if (!indices.containsKey(name)) {
      return indices[name] = MultipleIndex(getKey, compare)..addAll(data);
    } else {
      throw ArgumentError('index $name already exists');
    }
  }

  Index<Key, Record>? removeIndex(String name) {
    return indices.remove(name);
  }

  Record? get(Key key) => primaryIndex.getOne(key);

  @override
  Iterator<Record> get iterator => data.iterator;

  Future saveAll(List<Record> records) async {
    for (var record in records) {
      await save(record);
    }
  }

  Future save(Record record) async {
    var key = primaryIndex.getKey(record);
    // Save key to source, which will (reactively) notify this reservoir of the
    // new key and construct a new model, also updating any associated indices.
    await source.save(key, record);
  }

  Future remove(Record record) async {
    var key = primaryIndex.getKey(record);
    if (primaryIndex.has(key)) {
      // Remove key from source, which will (reactively) notify this reservoir
      // and then remove the key and any associated keys in indices.
      await source.remove(key);
    } else {
      throw ArgumentError('record not found for $key');
    }
  }

  Change addRecord(key, Record record) {
    _addToIndices(record);
    primaryIndex.add(record);
    return Added(key, record);
  }

  void _addToIndices(Record record) {
    for (var index in indices.values) {
      index.add(record);
    }
  }

  Change updateRecord(key, Record record) {
    _updateIndices(key, record);
    primaryIndex.add(record);
    return Updated(key, record);
  }

  void _updateIndices(key, Record record) {
    for (var index in indices.values) {
      index.add(record);
    }
  }

  Change removeRecord(key) {
    _removeFromIndices(primaryIndex.getOne(key)!);
    primaryIndex.remove(key);
    return Removed(key);
  }

  void _removeFromIndices(Record record) {
    for (var index in indices.values) {
      index.remove(record);
    }
  }

  @override
  String toString() => 'Reservoir($source, '
      'size: ${data.length}, '
      'indices: ${indices.keys.toList().join(",")})';
}
