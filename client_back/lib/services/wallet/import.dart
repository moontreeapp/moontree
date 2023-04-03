import 'dart:convert';
import 'package:bip39/bip39.dart' as bip39;
import 'package:wallet_utils/wallet_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';

class HandleResult {
  HandleResult(this.success, this.location, this.message);
  final bool success;
  final String location;
  final LingoKey message;
}

class ImportWalletService {
  Future<String> Function(String id)? _getEntropy;
  Future<void> Function(Secret secret)? _saveSecret;

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
      final Map<String, dynamic> jsonObj =
          json.decode(text) as Map<String, dynamic>;
      if (jsonObj['wallets'] == null) {
        return false;
      }
      final Map<String, dynamic> wallets =
          jsonObj['wallets']! as Map<String, dynamic>;
      for (final dynamic walletObj in wallets.values) {
        if (!<bool>[
          true,
          false
        ].contains((walletObj as Map<String, dynamic>)['backed up'] as bool)) {
          return false;
        }
        if (walletObj['wallet name'] is! String) {
          return false;
        }
        if (walletObj['secret'] is! String) {
          return false;
        }

        /// Ensure we can actually decrypt
        //final importType = typeForImport(walletObj['wallet type']);
        //final secret = wallet_obj['secret'] as String;
        //final cipherUpdate =
        //    CipherUpdate.fromMap(wallet_obj['cipher encryption']);
        //final cipher = pros.ciphers.primaryIndex
        //    .getOne(cipherUpdate.cipherType, cipherUpdate.passwordId)!;
        //if (importType == WalletType.leader) {
        //  //Encrypted Entropy
        //  final entropy = hex.decrypt(secret, cipher.cipher);
        //  bip39.entropyToMnemonic(entropy);
        //} else if (importType == WalletType.single) {
        //  //Encrypted WIF
        //  EncryptedWIF(secret, cipher.cipher).secret;
        //}
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

    final Map<String, dynamic> decodedJSON =
        json.decode(text) as Map<String, dynamic>;
    if (decodedJSON['wallets'] != null) {
      /// create wallets
      final List<HandleResult> results = <HandleResult>[];
      final Map<String, dynamic> wallets =
          decodedJSON['wallets']! as Map<String, dynamic>;
      for (final MapEntry<String, dynamic> entry in wallets.entries) {
        final Wallet? wallet = await services.wallet.create(
          walletType: typeForImport(
              (entry.value as Map<String, dynamic>)['wallet type'] as String),
          cipherUpdate: services.cipher.currentCipherUpdate,
          secret: (entry.value as Map<String, dynamic>)['secret'] as String?,
          name: (entry.value as Map<String, dynamic>)['wallet name'] as String?,
          alwaysReturn: true,
          getSecret: _getEntropy,
          saveSecret: _saveSecret,
        );
        results.add(await attemptWalletSave(wallet));
      }
      return results;
    }
    //} catch (e) {}
    // fix later: validate the json before it gets here. then parse it here.
    return <HandleResult>[
      HandleResult(false, '', LingoKey.leaderWalletSecretType /* todo fix */)
    ];
  }

  Future<HandleResult> handleMnemonics(String text) async =>
      attemptWalletSave(await services.wallet.create(
        walletType: WalletType.leader,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: text,
        alwaysReturn: true,
        getSecret: _getEntropy,
        saveSecret: _saveSecret,
      ));

  /*
  Future<HandleResult> handleMasterKey(String text) async {
    final node = bip32.BIP32.fromBase58(text);

    return attemptWalletSave(wallet);
  }
  */

  Future<HandleResult> handlePrivateKey(String text) async =>
      attemptWalletSave(await services.wallet.create(
        walletType: WalletType.single,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: services.wallet.single.privateKeyToWif(text),
        alwaysReturn: true,
        getSecret: _getEntropy,
        saveSecret: _saveSecret,
      ));

  Future<HandleResult> handleWIF(String text) async =>
      attemptWalletSave(await services.wallet.create(
        walletType: WalletType.single,
        cipherUpdate: services.cipher.currentCipherUpdate,
        secret: text,
        alwaysReturn: true,
        getSecret: _getEntropy,
        saveSecret: _saveSecret,
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
    ImportFormat importFormat,
    String text,
    Future<String> Function(String id)? getEntropy,
    Future<void> Function(Secret secret)? saveSecret,
  ) async {
    _getEntropy = getEntropy;
    _saveSecret = saveSecret;
    final Object results = await () {
      switch (importFormat) {
        case ImportFormat.json:
          return handleJson;
        case ImportFormat.mnemonic:
          return handleMnemonics;
        case ImportFormat.encryptedBip38:
          return handleBip38;
        case ImportFormat.privateKey:
          return handlePrivateKey;
        case ImportFormat.WIF:
          return handleWIF;
        case ImportFormat.jsonWif:
          return handleNotImplemented;
        case ImportFormat.jsonMt:
          return handleNotImplemented;
        case ImportFormat.seed:
          return handleNotImplemented;
        case ImportFormat.masterKey:
          return handleNotImplemented;
        case ImportFormat.invalid:
          return handleNotImplemented;
      }
    }()(text);
    if (results is List<HandleResult>) {
      return results;
    }
    return <HandleResult>[results as HandleResult];
  }

  Future<HandleResult> handleNotImplemented(String _) async =>
      HandleResult(false, 'not implemented', LingoKey.walletUnableToCreate);

  String? detectExistingWallet(Wallet wallet) =>
      pros.wallets.primaryIndex.getOne(wallet.id)?.id;

  Future<HandleResult> attemptWalletSave(Wallet? wallet) async {
    if (wallet != null) {
      final String? existingWalletId = detectExistingWallet(wallet);
      if (existingWalletId == null) {
        // since we're importing we assume the user has it backed up already
        wallet.backedUp = true;
        wallet.skipHistory = services.wallet.currentWallet.minerMode;
        final Change<Wallet>? importedChange = await pros.wallets.save(wallet);
        // set it as current before returning
        await pros.settings.setCurrentWalletId(importedChange!.record.id);
        return HandleResult(
            true,
            pros.wallets.primaryIndex.getOne(importedChange.record.id)!.name,
            LingoKey.walletImportedAs);
      }
      return HandleResult(
          false,
          pros.wallets.primaryIndex.getOne(wallet.id)!.name,
          LingoKey.walletAlreadyExists);
    }
    return HandleResult(false, '', LingoKey.walletUnableToCreate);
  }
}
