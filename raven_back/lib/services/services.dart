import 'account.dart';
import 'address.dart';
import 'balance.dart';
import 'client.dart';
import 'history.dart';
import 'password.dart';
import 'rate.dart';
import 'transaction.dart';
import 'wallet.dart';

class services {
  static AccountService accounts = AccountService();
  static AddressService addresses = AddressService();
  static BalanceService balances = BalanceService();
  static ClientService client = ClientService();
  static HistoryService histories = HistoryService();
  static RateService rates = RateService();
  static WalletService wallets = WalletService();
  static PasswordService passwords = PasswordService();
  static TransactionService transaction = TransactionService();
}
