typedef GetKey<Key, Record> = Key Function(Record);
typedef Compare<A> = int Function(A, A);

abstract class Index<Key, Record> {
  final GetKey<Key, Record> getKey;

  Index(this.getKey);

  Iterable<Key> get keys;
  Iterable<Record> get values;

  void add(Record record);
  void addAll(Iterable<Record> records) =>
      records.forEach((record) => add(record));
  Record? getOne(Key key);
  bool has(Key key) => getOne(key) != null;
  bool remove(Record record);
}
