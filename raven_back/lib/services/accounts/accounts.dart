import 'package:raven/services/service.dart';
import 'package:raven/reservoirs/reservoirs.dart';

class AccountsService extends Service {
  late final AccountReservoir accounts;
  late final WalletReservoir wallets;
  late final SettingReservoir settings;

  AccountsService(this.accounts, this.wallets, this.settings) : super();

  /// removes account if...
  /// no wallets assigned to it, and it's not the only account.
  /// if it's the current or preferred account, reassign
  Future<void> removeAccount(String accountId) async {
    var account = accounts.primaryIndex.getOne(accountId);
    if (account != null &&
        accounts.data.length > 1 &&
        wallets.byAccount.getAll(accountId).isEmpty) {
      //accounts.primaryIndex.remove(account); //required?
      await accounts.remove(account);
      if (account.id == settings.currentAccountId) {
        var newCurrentAccount = accounts.primaryIndex.getAny()!;
        await settings.setCurrentAccountId(newCurrentAccount.id);
      }
      if (account.id == settings.preferredAccountId) {
        var newPreferredAccount = accounts.primaryIndex.getAny()!;
        await settings.savePreferredAccountId(newPreferredAccount.id);
      }
    }
  }
}
