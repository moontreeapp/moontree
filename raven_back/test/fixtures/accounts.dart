import 'package:raven_back/records/records.dart';

Map<String, Account> get accounts {
  return {
    'account 0': Account(
      name: 'Account 0',
      accountId: '0',
    ),
    'account 1': Account(
      name: 'Account 1',
      accountId: 'account 1',
    ),
  };
}
