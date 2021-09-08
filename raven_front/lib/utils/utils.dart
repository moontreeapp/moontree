import 'package:flutter/widgets.dart';
import 'package:raven/raven.dart';

Map populateData(BuildContext context, data) => data != null && data.isNotEmpty
    ? data
    : ModalRoute.of(context)!.settings.arguments ?? {};

/// could make a hierarchy, or more simply, we could export a list of accounts, and a list of wallets...
//Map get accountsHierarchy => {
//      for (var account in accounts.data) ...{account.name: account.id}
//    };
//
//Map accountsWallets(Account account) => {
//      for (var wallet in wallets.byAccount.getAll(account.id)) ...{
//        wallet.id: [wallet.kind, wallet]
//      }
//      //      wallet.id,
//      //    ] ...{account.name: account.id}
//    };
//

Map<String, Map> get structureForExport => {
      'accounts': accountsForExport,
      'wallets': walletsForExport,
    };

Map<String, List> get accountsForExport => {
      for (var account in accounts.data) ...{
        account.id: [account.name, account.net]
      }
    };

Map<String, List> get walletsForExport => {
      for (var wallet in wallets.data) ...{
        wallet.id: [wallet.accountId, wallet.cipher, wallet.kind, wallet.secret]
      }
    };
