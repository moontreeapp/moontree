import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'change.dart';
import 'index.dart';
import 'source.dart';

export 'hive_source.dart';

const PRIMARY_INDEX = '_primary';

class Reservoir<Key, Record extends Equatable> with IterableMixin<Record> {
  final Source<Key, Record> source;
  final Map<String, Index<Key, Record>> indices = {};
  final StreamController<Change> _changes = StreamController();

  Stream<Change> get changes => _changes.stream;

  Iterable<Record> get data => primaryIndex.values;

  @override
  Iterator<Record> get iterator => data.iterator;

  UniqueIndex<Key, Record> get primaryIndex =>
      indices[PRIMARY_INDEX]! as UniqueIndex<Key, Record>;

  Reservoir(this.source, GetKey<Key, Record> getKey) {
    indices[PRIMARY_INDEX] = UniqueIndex(getKey);
    source.initialLoad(_addToIndices);
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

  Future<Change?> save(Record record) async {
    var key = primaryIndex.getKey(record);
    var change = await source.save(key, record);
    if (change != null) {
      _addToIndices(record);
      _changes.sink.add(change);
    }
    return change;
  }

  Future<List<Change>> saveAll(List<Record> records) async {
    var changes = <Change>[];
    for (var record in records) {
      var change = await save(record);
      if (change != null) {
        changes.add(change);
      }
    }
    return changes;
  }

  Future<Change?> remove(Record record) async {
    var key = primaryIndex.getKey(record);
    var change = await source.remove(key);
    if (change != null) {
      _removeFromIndices(record);
    }
  }

  void _addToIndices(Record record) {
    for (var index in indices.values) {
      index.add(record);
    }
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
