import 'change.dart';
import 'index.dart';
import 'source.dart';

export 'hive_box_source.dart';

typedef Mapper<Record, Model> = Model Function(Record);

class Reservoir<Record, Model> {
  final Source<Record, Model> source;
  final Mapper<Record, Model> mapToModel;
  final Mapper<Model, Record> mapToRecord;
  final Map<String, Index> indices = {};
  final Map<dynamic, Model> data = {};
  late Stream<Change> changes;

  Reservoir(this.source, this.mapToModel, this.mapToRecord) {
    changes = source.watch(this);
  }

  void save(key) {
    if (data.containsKey(key)) {
      source.save(key, mapToRecord(data[key]!));
    } else {
      throw ArgumentError('record not found for $key');
    }
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
    var value = mapToModel(record);
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
    var value = mapToModel(record);
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
