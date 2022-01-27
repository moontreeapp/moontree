import 'account.dart';
import 'history.dart';
import 'balance.dart';
import 'busy.dart';
import 'cipher.dart';
import 'client.dart';
import 'transaction.dart';
import 'password.dart';
import 'rate.dart';
import 'wallet.dart';

class services {
  static AccountService account = AccountService();
  static HistoryService history = HistoryService();
  static BalanceService balance = BalanceService();
  static BusyService busy = BusyService();
  static CipherService cipher = CipherService();
  static ClientService client = ClientService();
  static TransactionService transaction = TransactionService();
  static RateService rate = RateService();
  static WalletService wallet = WalletService();
  static PasswordService password = PasswordService();
}
