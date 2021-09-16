import 'package:raven/services/service.dart';
import 'package:raven/records/records.dart';
import 'package:raven/reservoirs/reservoirs.dart';

class AccountGenerationService extends Service {
  late final AccountReservoir accounts;

  AccountGenerationService(this.accounts) : super();

  Account newAccount(String name, {Net net = Net.Test, String? accountId}) {
    if (accountId != null) {
      var account = accounts.primaryIndex.getOne(accountId);
      if (account != null) {
        return account;
      }
    }
    return Account(
        accountId: accounts.data.length.toString(), name: name, net: net);
  }

  Future<Account> makeSaveAccount(String name,
      {Net net = Net.Test, String? accountId}) async {
    var account = newAccount(name, net: net);
    await accounts.save(account);
    return account;
  }
}
