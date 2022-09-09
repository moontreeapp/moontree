import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:ravencoin_back/utilities/hex.dart' as hex;

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart';

import 'constants.dart';

class HandleResult {
  final bool success;
  final String location;
  final LingoKey message;
  HandleResult(this.success, this.location, this.message);
}

class ImportWalletService {
  // TODO: Unsure how to validate this
  ImportFormat detectImportType(String text) {
    if (validateJson(text)) {
      return ImportFormat.json;
    }

    //TODO: MULTI LANGUAGES OTHER THAN ENGLISH
    if (bip39.validateMnemonic(text.toLowerCase())) {
      return ImportFormat.mnemonic;
    }
    try {
      services.wallet.single.privateKeyToWif(text);
      return ImportFormat.privateKey;
    } catch (_) {}
    try {
      //TODO: Tell user that they are in the wrong network mode
      KPWallet.fromWIF(text, pros.settings.network);
      return ImportFormat.WIF;
    } catch (_) {}

    /*
    TODO:
    This will require reworks of how we save wallets
    We cannot go from key -> entropy and therefore cannot
    use the raw entropy for creating leader wallets

    try {
      final node = bip32.BIP32.fromBase58(text);
      if (node.privateKey == null) {
        throw Exception('This is a watch only');
      }
      // TODO: We assume that this is an extended private key
      // Could be private/public account/extended key
      return ImportFormat.masterKey;
    } catch (_) {}
    */

    /// these are placeholders, they must be checked
    //var isSeed = text.length == 128;

    /// if we were unable to find a import type, we should be able to check
    /// something to get a good idea if this is known invalid, rather than
    /// returning null. this is a placeholder for that.
    /// TODO: Shouldn't this just be the default?
    if (text.contains('[')) {
      return ImportFormat.invalid;
    }
    return ImportFormat.invalid;
  }

  WalletType typeForImport(String walletType) =>
      walletType == exportedLeaderType
          ? WalletType.leader
          : walletType == exportedSingleType
              ? WalletType.single
              : throw ArgumentError('Wallet must be leader or single');

  bool validateJson(String text) {
    try {
      final json_obj =
          json.decode(text) as Map<String, Map<String, Map<String, dynamic>>>;
      if (!json_obj.containsKey('wallets')) {
        return false;
      }
      for (final wallet_obj in json_obj['wallets']!.values) {
        final importType = typeForImport(wallet_obj['type']);
        if (!(wallet_obj['backedUp'] is bool)) {
          return false;
        }
        if (!(wallet_obj['name'] is String)) {
          return false;
        }
        if (!(wallet_obj['secret'] is String)) {
          return false;
        }
        final secret = wallet_obj['secret'] as String;
        final cipherUpdate = CipherUpdate.fromMap(wallet_obj['cipherUpdate']);
        final cipher = pros.ciphers.byCipherTypePasswordId
            .getOne(cipherUpdate.cipherType, cipherUpdate.passwordId)!;

        // Ensure we can actually decrypt
        if (importType == WalletType.leader) {
          //Encrypted Entropy
          final entropy = hex.decrypt(secret, cipher.cipher);
          bip39.entropyToMnemonic(entropy);
        } else if (importType == WalletType.single) {
          //Encrypted WIF
          EncryptedWIF(secret, cipher.cipher).secret;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<HandleResult>> handleJson(String text) async {
    //try {
    /// {
    ///   'wallets': {pros.wallets.id: values}
    /// }
    /// try decrypt file
    var decodedJSON = json.decode(text) as Map<String, dynamic>;
    if (decodedJSON.containsKey('wallets')) {
      /// create wallets
      var results = <HandleResult>[];
      for (var entry in decodedJSON['wallets']!.entries) {
        var wallet = services.wallet.create(
          walletType: typeForImport(entry.value['type']),
          cipherUpdate: services.cipher.currentCipherUpdate,
          secret: entry.value['secret'],
          alwaysReturn: true,
        );
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

  Future<HandleResult> handleMnemonics(String text) async =>
      await attemptWalletSave(services.wallet.create(
        walletType: WalletType.leader,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: text,
        alwaysReturn: true,
      ));

  /*
  Future<HandleResult> handleMasterKey(String text) async {
    final node = bip32.BIP32.fromBase58(text);

    return attemptWalletSave(wallet);
  }
  */

  Future<HandleResult> handlePrivateKey(String text) async =>
      attemptWalletSave(services.wallet.create(
        walletType: WalletType.single,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: services.wallet.single.privateKeyToWif(text),
        alwaysReturn: true,
      ));

  Future<HandleResult> handleWIF(String text) async =>
      attemptWalletSave(services.wallet.create(
        walletType: WalletType.single,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: text,
        alwaysReturn: true,
      ));

  Future<HandleResult> handleBip38(String text) async {
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
  //        ImportFormat importFormat, String text) =>
  //    {
  Future<List<HandleResult>> handleImport(
      ImportFormat importFormat, String text) async {
    var results = await {
      ImportFormat.json: handleJson,
      ImportFormat.mnemonic: handleMnemonics,
      ImportFormat.encryptedBip38: handleBip38,
      ImportFormat.privateKey: handlePrivateKey,
      //ImportFormat.masterKey: handleMasterKey,
      ImportFormat.WIF: handleWIF,
    }[importFormat]!(text);
    if (results is List<HandleResult>) {
      return results;
    }
    return [results as HandleResult];
  }

  String? detectExistingWallet(Wallet wallet) =>
      pros.wallets.primaryIndex.getOne(wallet.id)?.id;

  Future<HandleResult> attemptWalletSave(Wallet? wallet) async {
    if (wallet != null) {
      var existingWalletId = detectExistingWallet(wallet);
      if (existingWalletId == null) {
        // since we're importing we assume the user has it backed up already
        wallet.backedUp = true;
        var importedChange = await pros.wallets.save(wallet);
        // set it as current before returning
        await pros.settings.setCurrentWalletId(importedChange!.record.id);
        return HandleResult(
            true,
            'Wallet ${pros.wallets.primaryIndex.getOne(importedChange.record.id)!.name}',
            LingoKey.walletImportedAs);
      }
      return HandleResult(
          false,
          'Wallet ${pros.wallets.primaryIndex.getOne(wallet.id)!.name}',
          LingoKey.walletAlreadyExists);
    }
    return HandleResult(false, '', LingoKey.walletUnableToCreate);
  }
}
