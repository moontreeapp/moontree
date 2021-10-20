import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/raven.dart';
import 'package:raven_mobile/services/lookup.dart';

enum ImportFormat {
  json,
  jsonWif,
  jsonMt,
  mnemonic12,
  mnemonic24, // valid for rvn?
  encryptedBip38, // 58?
  WIF,
  seed,
  privateKey,
}

class ImportFrom {
  late String text;
  late String accountId;
  late ImportFormat importFormat;
  late String? importedTitle;
  late String? importedMsg;

  ImportFrom(this.text, {importFormat, accountId})
      : this.importFormat = importFormat ?? ImportFrom.detectImportType(text),
        this.accountId = accountId ?? Current.account.accountId;

  static ImportFormat? detectImportType(String text) {
    if (text.contains('[') || text.contains('{')) {
      /// todo must also contain some correct keys
      /// two types of json - ours and outside json formats
      return ImportFormat.json;
    }
    //var isMnemonic = [12, 18, 24].contains(text.split(' ').length);
    if (bip39.validateMnemonic(text)) {
      return ImportFormat.mnemonic12;
    }
    if (text.length == 64 && !text.contains(' ')) {
      return ImportFormat.privateKey;
    }
    if ([51, 52].contains(text.length) && !text.contains(' ')) {
      return ImportFormat.WIF;
    }
    if (text.startsWith('6P') && !text.contains(' ')) {
      return ImportFormat.encryptedBip38;
    }

    /// these are placeholders, they must be checked
    var isSeed = text.length == 128;

    //throw Exception('Could not recognize format');
  }

  /// returns the accountId of existing account
  String? detectExistingAccount(Account account) =>
      wallets.primaryIndex.getOne(account.accountId)?.accountId;

  /// returns the accountId of existing wallet
  String? detectExistingWallet(Wallet wallet) =>
      wallets.primaryIndex.getOne(wallet.walletId)?.accountId;

  Future<bool> attemptAccountSave(Account? account) async {
    if (account != null) {
      var existingAccountId = detectExistingAccount(account);
      if (existingAccountId == null) {
        var importedChange = await accounts.save(account);
        await settings.save(Setting(
            name: SettingName.Account_Current, value: account.accountId));
        importedTitle = 'Success';
        importedMsg =
            'Account successfully imported as ${accounts.primaryIndex.getOne(importedChange!.data.accountId)!.name}.';
        return true;
      }
      importedTitle = 'Unable to Import';
      importedMsg = 'Account already exists!';
      return false;
    }
    importedTitle = 'Unable to Import';
    importedMsg = 'Account was unable to be created for an unknown reason...';
    return false;
  }

  Future<bool> attemptWalletSave(Wallet? wallet) async {
    if (wallet != null) {
      var existingAccountId = detectExistingWallet(wallet);
      if (existingAccountId == null) {
        var importedChange = await wallets.save(wallet);
        //todo change to tuple
        importedTitle = 'Success';
        importedMsg =
            'Wallet successfully imported into the ${accounts.primaryIndex.getOne(importedChange!.data.accountId)!.name} account.';
        return true;
      }
      importedTitle = 'Unable to Import';
      importedMsg =
          'Wallet already exists in the ${accounts.primaryIndex.getOne(wallet.accountId)!.name} account...';
      return false;
    }
    importedTitle = 'Unable to Import';
    importedMsg = 'Wallet was unable to be created for an unknown reason...';
    return false;
  }

  Future<bool> handleJson() async {
    /// json format of entire account or all accounts (merge)
    try {
      /// {
      ///   'accounts': {accounts.id: values},
      ///   'wallets': {wallets.id: values}
      /// }
      /// try decrypt file
      var decodedJSON = json.decode(text) as Map<String, Map<String, dynamic>>;
      if (decodedJSON.containsKey('accounts') &&
          decodedJSON.containsKey('wallets')) {
        /// create accounts
        for (var entry in decodedJSON['accounts']!.entries) {
          Account account = services.accounts.newAccount(
            entry.value['name'],
            net: entry.value['net'],
            accountId: entry.key,
          );
          return attemptAccountSave(account);
        }

        /// create wallets
        for (var entry in decodedJSON['wallets']!.entries) {
          Wallet? wallet = services.wallets.create(
            humanTypeKey: entry.value['type'],
            accountId: entry.value['accountId'],
            cipherUpdate: CipherUpdate.fromMap(entry.value['cipherUpdate']),
            secret: entry.value['secret'],
            alwaysReturn: true,
          );
          return attemptWalletSave(wallet);
        }
      }
    } catch (e) {}
    return false;
  }

  Future<bool> handleMnemonics() async {
    Wallet? wallet = services.wallets.create(
      humanTypeKey: LingoKey.leaderWalletType,
      accountId: accountId,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<bool> handlePrivateKey() async {
    Wallet? wallet = services.wallets.create(
      humanTypeKey: LingoKey.singleWalletType,
      accountId: accountId,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
      secret: services.wallets.singles.privateKeyToWif(text),
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<bool> handleWIF() async {
    Wallet? wallet = services.wallets.create(
      humanTypeKey: LingoKey.singleWalletType,
      accountId: accountId,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<bool> handleBip38() async {
    /// check for bip38 encryption
    // 6P valid for rvn?
    if (text.startsWith('6P')) {
      /// prompt for password
      /// decrypt
      /// use key
    }
    return false;
  }

  Future<bool> handleImport() async => await {
        ImportFormat.json: handleJson,
        ImportFormat.mnemonic12: handleMnemonics,
        ImportFormat.encryptedBip38: handleBip38,
        ImportFormat.privateKey: handlePrivateKey,
        ImportFormat.WIF: handleWIF,
      }[importFormat]!();
}
