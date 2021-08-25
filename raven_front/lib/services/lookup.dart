import 'package:raven/init/reservoirs.dart' as res;
import 'package:raven/records.dart';

Account currentAccount() =>
    res.accounts.get(res.settings.getOne(SettingName.Current_Account)!.value)!;

Balance? currentBalance() => res.balances
    .getOne(res.settings.getOne(SettingName.Current_Account)!.value);

Balance emptyBalance() => Balance(
    accountId: res.settings.getOne(SettingName.Current_Account)!.value,
    security: RVN,
    confirmed: 0,
    unconfirmed: 0);

class Current {
  static Account get account => currentAccount();
  static Balance get balance => currentBalance() ?? emptyBalance();
}
