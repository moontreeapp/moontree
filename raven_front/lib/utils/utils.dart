import 'package:flutter/widgets.dart';
import 'package:raven/raven.dart';

Map populateData(BuildContext context, data) => data != null && data.isNotEmpty
    ? data
    : ModalRoute.of(context)!.settings.arguments ?? {};

/// this is a preliminary format - proprietary...
/// we should atleast save the wallets as WIF in the json file.
/// Ideally we can find a common json format and use that,
/// adding our account mapping as metadata.
/// otherwise, what might be better is to package it up as a zip,  // fyi zip could include asset assets.
/// that way we can make a folder hierarchy for accounts
/// and wif files for wallets.
/// at least that way its manually importable to something else, otherwise
/// the user must export wallets one at a time and save their private keys etc.
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
          //'wif': wallet.wif
          //'cipher': wallet.cipher.toString(),
          //'kind': wallet.kind,
          //'secret': wallet.secret
        } // each wallet should be WIF or something...
      }
    };
