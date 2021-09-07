part of 'account.dart';

class _IdKey extends Key<Account> {
  @override
  String getKey(Account account) => account.id;
}

extension ByIdMethodsForAccount on Index<_IdKey, Account> {
  Account? getOne(String accountId) => getByKeyStr(accountId).firstOrNull;
  Account? getAny() => values.firstOrNull;
}
