import 'index.dart';
import 'key.dart';

class IndexUnique<K extends Key<Record>, Record> extends Index<K, Record> {
  final Map<String, Record> _data = {};

  IndexUnique(K keyType) : super(keyType);

  @override
  Iterable<String> get keys => _data.keys;

  @override
  Iterable<Record> get values => _data.values;

  @override
  void clear() => _data.clear();

  @override
  void add(Record record) => _data[keyType.getKey(record)] = record;

  @override
  List<Record> getByKeyStr(String key) {
    if (_data.containsKey(key)) {
      return [_data[key]!];
    } else {
      return [];
    }
  }

  @override
  bool remove(Record record) {
    var key = keyType.getKey(record);
    if (_data.containsKey(key)) {
      _data.remove(key);
      return true;
    } else {
      return false;
    }
  }
}
