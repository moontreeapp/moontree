import 'account.dart';
import 'address.dart';
import 'balance.dart';
import 'history.dart';
import 'rate.dart';
import 'setting.dart';
import 'wallet.dart';

class services {
  static AccountService accounts = AccountService();
  static AddressService addresses = AddressService();
  static BalanceService balances = BalanceService();
  static HistoryService histories = HistoryService();
  static RateService rates = RateService();
  static SettingService settings = SettingService();
  static WalletService wallets = WalletService();
}
