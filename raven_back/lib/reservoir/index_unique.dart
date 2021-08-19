import 'index.dart';

class IndexUnique<Key, Record> extends Index<Key, Record> {
  final Map<Key, Record> _data = {};

  IndexUnique(getKey) : super(getKey);

  @override
  Iterable<Key> get keys => _data.keys;

  @override
  Iterable<Record> get values => _data.values;

  @override
  void add(Record record) => _data[getKey(record)] = record;

  @override
  Record? getOne(Key key) => _data[key];

  @override
  bool remove(Record record) {
    var key = getKey(record);
    if (_data.containsKey(key)) {
      _data.remove(key);
      return true;
    } else {
      return false;
    }
  }
}
