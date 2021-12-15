import 'key.dart';

typedef GetKey<K, Record> = K Function(Record);
typedef Compare<A> = int Function(A, A);

abstract class Index<K extends Key, Record> {
  final K keyType;

  Index(this.keyType);

  // subclasses must implement the following methods:
  // - keys
  // - values
  // - add
  // - remove
  // - getByKeyStr

  Iterable<String> get keys;
  Iterable<Record> get values;
  void clear();
  void add(Record record);
  bool remove(Record record);
  List<Record> getByKeyStr(String key);

  // the following methods MAY be overridden, but need not be

  void addAll(Iterable<Record> records) => records.forEach(add);
  bool has(String key) => getByKeyStr(key).isNotEmpty;
}
