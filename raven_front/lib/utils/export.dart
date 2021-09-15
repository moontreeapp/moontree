import 'package:raven/raven.dart';

/// export format:
/// {
///   'accounts': [{object details}, {object details}, ...],
///   'wallets': [{object details}, {object details}, ...],
/// }
/// structure is flat and contains no constraints
/// because we want it to be generalized so it's adopted by others.
/// this allows for duplicates: wallets can belong to multiple accounts,
/// and multiple accounts or wallets can have the same name and id.
/// allows for other keys to be appeneded too.
Map<String, List<Map<String, dynamic>>> structureForExport(Account? account) =>
    {
      'accounts': accountsForExport(account),
      'wallets': walletsForExport(account),
    };

List<Map<String, dynamic>> accountsForExport(Account? account) => [
      for (var account in account != null ? [account] : accounts.data)
        {
          account.accountId: {
            'name': account.name,
            'net': account.net.toString()
          }
        }
    ];

List<Map<String, dynamic>> walletsForExport(Account? account) => [
      for (var wallet in account != null
          ? wallets.byAccount.getAll(account.accountId)
          : wallets.data)
        {
          wallet.walletId: {
            'accountId': wallet.accountId,
            'secret': wallet.secret // private key or seed phrase encrypted
          }
        }
    ];
