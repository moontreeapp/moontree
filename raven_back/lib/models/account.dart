import 'package:equatable/equatable.dart';
import 'package:raven/records.dart' as records;

class Account extends Equatable {
  final String id;
  final String name;

  Account({required this.id, required this.name}) : super();

  factory Account.fromRecord(records.Account record) {
    return Account(id: record.id, name: record.name);
  }

  records.Account toRecord() {
    return records.Account(id: id, name: name);
  }

  @override
  List<Object?> get props => [id];
}
