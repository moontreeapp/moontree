import 'package:raven/raven.dart';

/// entire file is encrypted
/// export format:
/// {
///   'accounts': {accounts.id: values},
///   'wallets': {wallets.id: values}
/// }
/// simply a json map with accounts and wallets as keys.
/// values in our system is another map with id as key,
/// other systems could use list or whatever.
Map<String, Map<String, dynamic>> structureForExport(Account? account) => {
      'accounts': accountsForExport(account),
      'wallets': walletsForExport(account),
    };

Map<String, dynamic> accountsForExport(Account? account) => {
      for (var account in account != null ? [account] : accounts.data) ...{
        account.accountId: {'name': account.name, 'net': account.net.toString()}
      }
    };

Map<String, dynamic> walletsForExport(Account? account) => {
      for (var wallet in account != null ? account.wallets : wallets.data) ...{
        wallet.walletId: {
          'accountId': wallet.accountId,
          'secret': wallet.secret(cipherRegistry.ciphers[wallet.cipherUpdate]!),
          'type': wallet.humanTypeKey,
          'cipherUpdate': wallet.cipherUpdate.toMap,
        }
      }
    };
