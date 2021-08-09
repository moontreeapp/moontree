import 'dart:async';

import 'package:hive/hive.dart';
import 'package:raven/models.dart';
import 'package:raven/records/net.dart';
import 'package:raven/reservoir/change.dart';
import 'package:raven/reservoirs/account.dart';
import 'package:raven/reservoirs/wallet.dart';
import 'package:raven/services/service.dart';
import 'package:raven/utils/cipher.dart';

class MasterWalletService extends Service {
  AccountReservoir accounts;
  WalletReservoir wallets;
  late StreamSubscription<Change> listener;

  MasterWalletService(this.accounts, this.wallets) : super();

  @override
  Future init() async {
    // set up listener on new account generation -
    listener = accounts.changes.listen((change) {
      change.when(
          added: (added) {
            var account = added.data;
            // verify empty
            if (wallets.byAccount.getAll(account.accountId).isEmpty) {
              // populate with new LeaderWallet created from the master wallet
              makeNewLeaderWallet(account.accountId);
            }
          },
          updated: (updated) {
            /* Name or settings have changed */
          },
          removed: (removed) {});
    });
  }

  @override
  void deinit() {
    // listener.cancel();
  }

  void makeNewLeaderWallet(String accountId) {
    _saveLeaderWallet(_deriveNewLeaderWallet(accountId));
  }

  LeaderWallet _makeMasterWallet() {
    return LeaderWallet.fromEncryptedSeed(
        encryptedSeed:
            Hive.box<dynamic>('settings').get('master.encryptedSeed'),
        leaderWalletIndex: -1,
        accountId: '_',
        net: Net.Test,
        cipher: const NoCipher());
  }

  LeaderWallet _deriveNewLeaderWallet(String accountId) {
    return _makeMasterWallet().deriveNextLeader(accountId);
  }

  void _saveLeaderWallet(LeaderWallet leaderWallet) {
    wallets.save(leaderWallet);
  }
}
