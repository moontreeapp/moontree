import 'download/download.dart';

import 'authentication.dart';
import 'balance.dart';
import 'cipher.dart';
import 'client.dart';
import 'transaction/transaction.dart';
import 'password.dart';
import 'rate.dart';
import 'tutorial.dart';
import 'wallet.dart';
import 'version.dart';

class services {
  static BalanceService balance = BalanceService();
  static CipherService cipher = CipherService();
  static ClientService client = ClientService();
  static TransactionService transaction = TransactionService();
  static RateService rate = RateService();
  static WalletService wallet = WalletService();
  static PasswordService password = PasswordService();
  static AuthenticationService authentication = AuthenticationService();
  static DownloadService download = DownloadService();
  static TutorialService tutorial = TutorialService();
  static VersionService version = VersionService();
}
