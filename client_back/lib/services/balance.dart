/// balances are by wallet
/// if you want the balance of a subwallet (address) then get it from Histories.

// ignore_for_file: omit_local_variable_types
import 'package:client_back/client_back.dart';

class BalanceService {
  /// Wallet Aggregation Logic ////////////////////////////////////////////////

  Balance walletBalance(Wallet wallet, Security security) {
    Balance retBalance =
        Balance(walletId: '', confirmed: 0, unconfirmed: 0, security: security);
    for (final Balance balance in wallet.balances) {
      if (balance.security == security) {
        retBalance = retBalance + balance;
      }
    }
    return retBalance;
  }
}
