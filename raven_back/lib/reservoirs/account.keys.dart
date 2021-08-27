part of 'account.dart';

class _IdKey extends Key<Account> {
  @override
  String getKey(Account account) => account.id;
}

extension ByIdMethodsForAccount on Index<_IdKey, Account> {
  Account? getOne(String accountId) {
    var accounts = getByKeyStr(accountId);
    return accounts.isEmpty ? null : accounts.first;
  }
}
