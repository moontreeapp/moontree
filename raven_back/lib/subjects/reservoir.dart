import 'package:hive/hive.dart';

import 'change.dart';
import 'index.dart';

typedef Mapper<Record, Model> = Model Function(Record);

abstract class Source<Record, Model> {
  /// The `watch` method is responsible for 2 things:
  /// 1. adding, updating, and removing key/value pairs in the Reservoir, and
  /// 2. returning a stream of changes that match the action taken.
  Stream<Change> watch(Reservoir<Record, Model> reservoir);
}

class HiveBoxSource<Record, Model> extends Source<Record, Model> {
  final String name;
  late final Box<Record> box;

  HiveBoxSource(this.name);

  @override
  Stream<Change> watch(Reservoir<Record, Model> reservoir) {
    box = Hive.box<Record>(name);

    // Populate initial data from Hive box
    for (var entry in box.toMap().entries) {
      reservoir.addRecord(entry.key, entry.value);
      // reservoir.data[entry.key] = mapper(entry.value);
    }

    // Subscribe to future updates to data
    return box.watch().map((BoxEvent e) {
      var key = e.key;
      Record value = e.value;
      var exists = reservoir.data.containsKey(key);
      if (e.deleted) return reservoir.removeRecord(key);
      if (!exists) return reservoir.addRecord(key, value);
      return reservoir.updateRecord(key, value);
    });
  }
}

class Reservoir<Record, Model> {
  final Source<Record, Model> source;
  final Mapper<Record, Model> mapper;
  final Map<String, Index> indices = {};
  final Map<dynamic, Model> data = {};
  late Stream<Change> changes;

  Reservoir(this.source, this.mapper) {
    changes = source.watch(this);
  }

  Index addIndex(String name, GetKey<Model> getKey, [Compare? compare]) {
    if (!indices.containsKey(name)) {
      return indices[name] = Index(getKey, data.values, compare);
    } else {
      throw ArgumentError('index $name already exists');
    }
  }

  Index? removeIndex(String name) {
    return indices.remove(name);
  }

  Change addRecord(key, Record record) {
    var value = mapper(record);
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
    var value = mapper(record);
    _updateIndices(key, value, data[key]!);
    data[key] = value;
    return Updated(key, value);
  }

  void _updateIndices(key, Model value, Model oldValue) {
    for (var index in indices.values) {
      index.update(value, oldValue);
    }
  }

  Change removeRecord(key) {
    _removeFromIndices(data[key]!);
    data.remove(key);
    return Removed(key);
  }

  void _removeFromIndices(Model value) {
    for (var index in indices.values) {
      index.remove(value);
    }
  }

  @override
  String toString() => 'Reservoir($source, '
      'size: ${data.length}, '
      'indices: ${indices.keys.toList().join(",")})';
}
