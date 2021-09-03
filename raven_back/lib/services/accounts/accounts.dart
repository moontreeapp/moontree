import 'package:raven/services/service.dart';
import 'package:raven/reservoirs/reservoirs.dart';

class AccountsService extends Service {
  late final AccountReservoir accounts;
  late final WalletReservoir wallets;

  AccountsService(this.accounts, this.wallets) : super();

  void removeAccount(String accountId) {
    var account = accounts.primaryIndex.getOne(accountId);
    if (account != null && wallets.byAccount.getAll(accountId).isEmpty) {
      accounts.primaryIndex.remove(account);
    }
  }
}
