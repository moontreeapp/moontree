import 'package:equatable/equatable.dart';
import 'package:raven/records.dart' as records;

class Account extends Equatable {
  final String accountId;
  final String name;

  Account({required this.accountId, required this.name}) : super();

  factory Account.fromRecord(records.Account record) {
    return Account(accountId: record.accountId, name: record.name);
  }

  records.Account toRecord() {
    return records.Account(accountId: accountId, name: name);
  }

  @override
  List<Object?> get props => [accountId];

  String get id => accountId;
}
