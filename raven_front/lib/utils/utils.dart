import 'package:flutter/widgets.dart';
import 'package:raven/raven.dart';

Map populateData(BuildContext context, data) => data != null && data.isNotEmpty
    ? data
    : ModalRoute.of(context)!.settings.arguments ?? {};

Map<String, Map> structureForExport(Account? account) => {
      'accounts': accountsForExport(account),
      'wallets': walletsForExport(account),
    };

Map<String, Map<String, dynamic>> accountsForExport(Account? account) => {
      for (var account in account != null ? [account] : accounts.data) ...{
        account.id: {'name': account.name, 'net': account.net.toString()}
      }
    };

Map<String, Map<String, dynamic>> walletsForExport(Account? account) => {
      for (var wallet in account != null
          ? wallets.byAccount.getAll(account.id)
          : wallets.data) ...{
        wallet.id: {
          'accountId': wallet.accountId,
          'cipher': wallet.cipher.toString(),
          'kind': wallet.kind,
          'secret': wallet.secret
        } // each wallet should be WIF or something...
      }
    };
