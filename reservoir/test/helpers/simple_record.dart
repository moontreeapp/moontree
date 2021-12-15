import 'package:equatable/equatable.dart';
import 'package:reservoir/index_multiple.dart';
import 'package:reservoir/key.dart';

class SimpleRecord with EquatableMixin {
  final String key;
  final String value;
  SimpleRecord(this.key, this.value);

  @override
  List<Object?> get props => [key];

  @override
  bool? get stringify => true;
}

// by SimpleRecord.value

class ValueKey extends Key<SimpleRecord> {
  @override
  String getKey(SimpleRecord record) => record.value;
}

extension ByValue on IndexMultiple<ValueKey, SimpleRecord> {
  List<SimpleRecord> getAll(String value) => getByKeyStr(value);
}

// by SimpleRecord.key

class KeyKey extends Key<SimpleRecord> {
  @override
  String getKey(SimpleRecord record) => record.key;
}

extension ByKey on IndexMultiple<KeyKey, SimpleRecord> {
  List<SimpleRecord> getAll(String value) => getByKeyStr(value);
}
