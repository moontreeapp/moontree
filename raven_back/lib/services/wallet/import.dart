import 'dart:convert';
import 'dart:ffi';

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/raven.dart';

import 'constants.dart';

class HandleResult {
  final bool success;
  final String location;
  final LingoKey message;
  HandleResult(this.success, this.location, this.message);
}

class ImportWalletService {
  ImportFormat? detectImportType(String text) {
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
  }

  WalletType typeForImport(String walletType) =>
      walletType == exportedLeaderType
          ? WalletType.leader
          : walletType == exportedSingleType
              ? WalletType.single
              : throw ArgumentError('Wallet must be leader or single');

  Future<List<HandleResult>> handleJson(String text, String accountId) async {
    /// json format of entire account or all accounts (merge)
    print('IN JSON ---$text');
    //try {
    /// {
    ///   'accounts': {accounts.id: values},
    ///   'wallets': {wallets.id: values}
    /// }
    /// try decrypt file
    var decodedJSON = json.decode(text) as Map<String, dynamic>;
    print('JSON DECODE');
    print(decodedJSON);
    if (decodedJSON.containsKey('accounts') &&
        decodedJSON.containsKey('wallets')) {
      /// create accounts
      // ignore: omit_local_variable_types
      Map<String, String> accountIds = {};
      for (var entry in decodedJSON['accounts']!.entries) {
        var account = Account(
            accountId: entry.key,
            name: entry.value['name'],
            net: entry.value['net'] == 'Net.Test' ? Net.Test : Net.Main);
        accountIds.addAll(await attemptAccountSave(account));
      }
      print('accountIds $accountIds');

      /// create wallets
      var results = <HandleResult>[];
      for (var entry in decodedJSON['wallets']!.entries) {
        print('importing $entry');
        print('CIPHER UPDATE---${entry.value['cipherUpdate']}');
        print(ciphers.data);
        var wallet = services.wallet.create(
          walletType: typeForImport(entry.value['type']),
          accountId: accountIds[entry.value['accountId']]!,

          /// we should use the current cipher:
          // cipherUpdate: CipherUpdate.fromMap(entry.value['cipherUpdate']),
          cipherUpdate: services.cipher.currentCipherUpdate,

          secret: entry.value['secret'],
          alwaysReturn: true,
        );
        print('saving $wallet');
        results.add(await attemptWalletSave(wallet));
      }
      return results;
    }
    //} catch (e) {}
    // fix later: validate the json before it gets here. then parse it here.
    return [
      HandleResult(false, '', LingoKey.leaderWalletSecretType /* todo fix */)
    ];
  }

  Future<HandleResult> handleMnemonics(String text, String accountId) async {
    //HandleResult handleMnemonics(String text, String accountId) {
    var wallet = services.wallet.create(
      walletType: WalletType.leader,
      accountId: accountId,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<HandleResult> handlePrivateKey(String text, String accountId) async {
    var wallet = services.wallet.create(
      walletType: WalletType.single,
      accountId: accountId,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: services.wallet.single.privateKeyToWif(text),
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<HandleResult> handleWIF(String text, String accountId) async {
    var wallet = services.wallet.create(
      walletType: WalletType.single,
      accountId: accountId,
      cipherUpdate: services.cipher.currentCipherUpdate,
      secret: text,
      alwaysReturn: true,
    );
    return attemptWalletSave(wallet);
  }

  Future<HandleResult> handleBip38(String text, String accountId) async {
    /// check for bip38 encryption
    // 6P valid for rvn?
    if (text.startsWith('6P')) {
      /// prompt for password
      /// decrypt
      /// use key
    }
    return HandleResult(
        false, '', LingoKey.leaderWalletSecretType /* todo fix */);
  }

  //HandleResult handleImport(
  //        ImportFormat importFormat, String text, String accountId) =>
  //    {
  Future<List<HandleResult>> handleImport(
      ImportFormat importFormat, String text, String accountId) async {
    var results = await {
      ImportFormat.json: handleJson,
      ImportFormat.mnemonic12: handleMnemonics,
      ImportFormat.encryptedBip38: handleBip38,
      ImportFormat.privateKey: handlePrivateKey,
      ImportFormat.WIF: handleWIF,
    }[importFormat]!(text, accountId);
    if (results is List<HandleResult>) {
      return results;
    }
    return [results as HandleResult];
  }

  /// returns the accountId of existing account
  String? detectExistingAccount(Account account) =>
      accounts.primaryIndex.getOne(account.accountId)?.accountId;

  /// returns the accountId of existing wallet
  String? detectExistingWallet(Wallet wallet) =>
      wallets.primaryIndex.getOne(wallet.walletId)?.accountId;

  /// returns the accountId of existing account
  List detectExistingAccountByName(Account account) =>
      accounts.byName.getAll(account.name);

  /// we even if an account by the same name exists we should import
  /// (with date appended) remember the id's and use those for the wallets.
  Future<Map<String, String>> attemptAccountSave(Account? account) async {
    if (account != null) {
      var existingAccountId = detectExistingAccount(account);
      print('${account.accountId}---------existingAccountId');
      print(existingAccountId);
      var originalId = account.accountId;
      if (existingAccountId != null) {
        account.accountId = accounts.nextId;
        print('ACCOUNTID: $originalId, ${account.accountId}');
      }
      await accounts.save(account);
      await settings.save(
          Setting(name: SettingName.Account_Current, value: account.accountId));
      return {originalId: account.accountId};
    }
    // todo: handle?
    return {'fail': 'fail'};
  }

  Future<HandleResult> attemptWalletSave(Wallet? wallet) async {
    if (wallet != null) {
      var existingAccountId = detectExistingWallet(wallet);
      if (existingAccountId == null) {
        var importedChange = await wallets.save(wallet);
        return HandleResult(
            true,
            accounts.primaryIndex.getOne(importedChange!.data.accountId)!.name,
            LingoKey.walletImportedAs);
      }
      return HandleResult(
          false,
          accounts.primaryIndex.getOne(wallet.accountId)!.name,
          LingoKey.walletAlreadyExists);
    }
    return HandleResult(false, '', LingoKey.walletUnableToCreate);
  }
}
