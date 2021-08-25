import 'package:raven/services/service.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';

class AccountGenerationService extends Service {
  late final AccountReservoir accounts;

  AccountGenerationService(this.accounts) : super();

  Account newAccount(String name, {Net net = Net.Test}) {
    return Account(id: accounts.data.length.toString(), name: name, net: net);
  }

  Account makeAndSaveAccount(String name, {Net net = Net.Test}) {
    var account = newAccount(name, net: net);
    accounts.save(account);
    return account;
  }
  
  Future<Account> makeAndAwaitSaveAccount(String name, {Net net = Net.Test}) async {
    var account = newAccount(name, net: net);
    await accounts.save(account);
    return account;
  }
}
