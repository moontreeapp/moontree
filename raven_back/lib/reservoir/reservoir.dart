import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';

import 'change.dart';
import 'index.dart';
import 'index_unique.dart';
import 'index_multiple.dart';
import 'source.dart';

export 'hive_source.dart';
export 'index.dart';
export 'index_unique.dart';
export 'index_multiple.dart';

const PRIMARY_INDEX = '_primary';

class Reservoir<Key, Rec extends EquatableMixin> with IterableMixin<Rec> {
  final Source<Key, Rec> source;
  final Map<String, Index<Key, Rec>> indices = {};
  final StreamController<List<Change>> _changes = StreamController();

  /// Expose the stream of changes that can be subscribed to
  Stream<List<Change>> get changes => _changes.stream;

  /// Return all records in the Reservoir
  Iterable<Rec> get data => primaryIndex.values;

  /// Allow to iterate over all the records in the Reservoir
  ///   e.g. `for (row in reservoir) { ... }`
  @override
  Iterator<Rec> get iterator => data.iterator;

  /// Return the `primaryIndex` from the set of indices
  IndexUnique<Key, Rec> get primaryIndex =>
      indices[PRIMARY_INDEX]! as IndexUnique<Key, Rec>;

  /// Given a record, return its key as stored in the `primaryIndex`
  Key primaryKey(record) => primaryIndex.getKey(record);

  /// Give a key, return the corresponding record in the `primaryIndex`
  Rec? get(Key key) => primaryIndex.getOne(key);

  /// Construct a Reservoir from a `source`. Requires `getKey` as a function
  /// that maps a Record to a Key, so that the Reservoir can construct a
  /// `primaryIndex`.
  Reservoir(this.source, GetKey<Key, Rec> getKey) {
    indices[PRIMARY_INDEX] = IndexUnique(getKey);
    source.initialLoad().forEach(_addToIndices);
  }

  /// Create a unique index and add all current records to it
  IndexUnique<Key, Rec> addIndexUnique(String name, GetKey<Key, Rec> getKey) {
    _assertNewIndexName(name);
    return indices[name] = IndexUnique(getKey)..addAll(data);
  }

  /// Create a 'multiple' index and add all current records to it
  IndexMultiple<Key, Rec> addIndexMultiple(String name, GetKey<Key, Rec> getKey,
      [Compare? compare]) {
    _assertNewIndexName(name);
    return indices[name] = IndexMultiple(getKey, compare)..addAll(data);
  }

  /// Save a `record`, index it, and broadcast the change
  Future<Change?> save(Rec record) async {
    return await _saveSilently(record)
      ?..ifChanged((change) => _changes.sink.add([change]));
  }

  /// Remove a `record`, de-index it, and broadcast the change
  Future<Change?> remove(Rec record) async {
    return await _removeSilently(record)
      ?..ifChanged((change) => _changes.sink.add([change]));
  }

  /// Save all `records`, index them, and broadcast the changes
  Future<List<Change>> saveAll(List<Rec> records) async {
    return _changeAll(records, _saveSilently);
  }

  /// Remove all `records`, de-index them, and broadcast the changes
  Future<List<Change>> removeAll(List<Rec> records) async {
    return _changeAll(records, _removeSilently);
  }

  // Index & save one record without broadcasting any changes
  Future<Change?> _saveSilently(Rec record) async {
    return await source.save(primaryKey(record), record)
      ?..ifChanged((record) => _addToIndices(record));
  }

  // De-index & remove one record without broadcasting any changes
  Future<Change?> _removeSilently(Rec record) async {
    return await source.remove(primaryKey(record))
      ?..ifChanged((record) => _removeFromIndices(record));
  }

  // Apply a change function to each of the `records`, returning the changes
  Future<List<Change>> _changeAll(List<Rec> records, changeFn) async {
    var changes = <Change>[];
    for (var record in records) {
      var change = await changeFn(record);
      if (change != null) changes.add(change);
    }
    return changes;
  }

  // Add record to all indices, including primary index
  void _addToIndices(Rec record) {
    indices.values.forEach((index) => index.add(record));
  }

  // Remove record from all indices, including primary index
  void _removeFromIndices(Rec record) {
    indices.values.forEach((index) => index.remove(record));
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
