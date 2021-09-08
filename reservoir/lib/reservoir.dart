library reservoir;

import 'dart:async';
import 'dart:collection';

import 'package:rxdart/rxdart.dart';

import 'change.dart';
import 'key.dart';
import 'index.dart';
import 'index_unique.dart';
import 'index_multiple.dart';
import 'source.dart';

export 'change.dart';
export 'key.dart';

export 'index.dart';
export 'index_unique.dart';
export 'index_multiple.dart';

export 'source.dart';
export 'map_source.dart';
export 'hive_source.dart';

const PRIMARY_INDEX = '_primary';

class Reservoir<PrimaryKey extends Key<Record>, Record extends Object>
    with IterableMixin<Record> {
  final Map<String, Index<Key<Record>, Record>> indices = {};
  final PublishSubject<List<Change>> _changes = PublishSubject();
  late Source<Record> source;

  /// Expose the stream of changes that can be subscribed to
  Stream<List<Change>> get changes => _changes.stream;

  /// Return all records in the Reservoir
  Iterable<Record> get data => primaryIndex.values;

  /// Allow to iterate over all the records in the Reservoir
  ///   e.g. `for (row in reservoir) { ... }`
  @override
  Iterator<Record> get iterator => data.iterator;

  /// Return the `primaryIndex` from the set of indices
  IndexUnique<PrimaryKey, Record> get primaryIndex =>
      indices[PRIMARY_INDEX]! as IndexUnique<PrimaryKey, Record>;

  /// Given a record, return its key as stored in the `primaryIndex`
  String primaryKey(record) => primaryIndex.keyType.getKey(record);

  /// Construct a Reservoir from a `source`. Requires `getKey` as a function
  /// that maps a Record to a Key, so that the Reservoir can construct a
  /// `primaryIndex`.
  Reservoir(Source<Record> source, PrimaryKey keyType) {
    indices[PRIMARY_INDEX] = IndexUnique<PrimaryKey, Record>(keyType);
    setSource(source);
  }

  setSource(Source<Record> source) {
    clear();
    this.source = source;
    source.initialLoad().forEach(_addToIndices);
  }

  /// Create a unique index and add all current records to it
  IndexUnique<K, Record> addIndexUnique<K extends Key<Record>>(
      String name, K keyType) {
    _assertNewIndexName(name);
    return indices[name] = IndexUnique<K, Record>(keyType)..addAll(data);
  }

  /// Create a 'multiple' index and add all current records to it
  IndexMultiple<K, Record> addIndexMultiple<K extends Key<Record>>(
      String name, K keyType,
      [Compare? compare]) {
    _assertNewIndexName(name);
    return indices[name] = IndexMultiple<K, Record>(keyType, compare)
      ..addAll(data);
  }

  /// Clear all data in reservoir, including all indices
  Future<List<Change>> clear() async {
    return await removeAll(data);
  }

  /// Save a `record`, index it, and broadcast the change
  Future<Change?> save(Record record) async {
    var change = await _saveSilently(record);
    if (change != null) _changes.add([change]);
    return change;
  }

  /// Remove a `record`, de-index it, and broadcast the change
  Future<Change?> remove(Record record) async {
    return await _removeSilently(record)
      ?..ifChanged((change) => _changes.add([change]));
  }

  /// Save all `records`, index them, and broadcast the changes
  Future<List<Change>> saveAll(Iterable<Record> records) async {
    return await _changeAll(records, _saveSilently);
  }

  /// Remove all `records`, de-index them, and broadcast the changes
  Future<List<Change>> removeAll(Iterable<Record> records) async {
    return await _changeAll(records, _removeSilently);
  }

  // Index & save one record without broadcasting any changes
  Future<Change?> _saveSilently(Record record) async {
    var change = await source.save(primaryKey(record), record);
    change?.when(
        added: (change) {
          _addToIndices(change.data);
        },
        updated: (change) {
          var oldRecord = primaryIndex.getByKeyStr(primaryKey(record))[0];
          _removeFromIndices(oldRecord);
          _addToIndices(change.data);
        },
        removed: (change) {});
    return change;
  }

  // De-index & remove one record without broadcasting any changes
  Future<Change?> _removeSilently(Record record) async {
    var change = await source.remove(primaryKey(record));
    if (change != null) _removeFromIndices(change.data);
    return change;
  }

  // Apply a change function to each of the `records`, returning the changes
  Future<List<Change>> _changeAll(Iterable<Record> records, changeFn) async {
    var changes = <Change>[];
    // must turn iterable into list so that records can be removed by changeFn
    for (var record in records.toList()) {
      var change = await changeFn(record);
      if (change != null) changes.add(change);
    }
    if (changes.isNotEmpty) {
      _changes.add(changes);
    }
    return changes;
  }

  // Add record to all indices, including primary index
  void _addToIndices(Record record) {
    for (var index in indices.values) index.add(record);
  }

  // Remove record from all indices, including primary index
  void _removeFromIndices(Record record) {
    for (var index in indices.values) index.remove(record);
  }

  // Throw an exception if index with `name` already exists
  void _assertNewIndexName(String name) {
    if (indices.containsKey(name)) {
      throw ArgumentError('index $name already exists');
    }
  }

  @override
  String toString() => 'Reservoir($source, '
      'size: ${data.length}, '
      'indices: ${indices.keys.toList().join(",")})';
}

extension on Change {
  // Shortcut chain method so we can call `?..ifChanged`
  void ifChanged(f) => f(this);
}
