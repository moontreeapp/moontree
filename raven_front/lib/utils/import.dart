import 'dart:convert';

import 'package:bip39/bip39.dart' as bip39;
import 'package:raven/raven.dart';

class FormatSeed {
  late String format;
  late String message;
  FormatSeed(this.format, this.message);
}

/// will detect what it is and import it if possible, returns message...
/// Here are the formats we need to check for:
/// 1. wallet mnemonic seed phrase Done
/// 1. private key
/// 2. json format of entire account (merge) Done
/// 2. json format of all accounts (merge) Done
///
/// encrypted HD wallet passphrase?
/// encrypted HD wallet seed
/// encrypted private key
/// wallet passphrase
/// private key
/// wif
Future<FormatSeed> handleImport(String text, String accountId) async {
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
        Account account = await accountGenerationService.makeSaveAccount(
            entry.value['name'],
            net: entry.value['net'],
            accountId: entry.key);
        await settingsService.saveSetting(
            SettingName.Account_Current, account.accountId);
      }

      /// create wallets
      for (var entry in decodedJSON['wallets']!.entries) {
        await walletService.createSave(
          humanType: entry.value['humanType'],
          accountId: entry.value['accountId'],
          cipherUpdate: CipherUpdate.fromMap(entry.value['cipherUpdate']),
          secret: entry.value['secret'],
        );
      }
    }
    return FormatSeed('json', 'success');
  } catch (e) {}

  /// is valid mnemonic?
  //var isMnemonic = [12, 18, 24].contains(text.split(' ').length);
  if (bip39.validateMnemonic(text)) {
    await leaderWalletGenerationService.makeSaveLeaderWallet(
      accountId,
      cipherRegistry.currentCipher,
      cipherUpdate: cipherRegistry.currentCipherUpdate,
      mnemonic: text,
    );
    return FormatSeed('mnemonic', 'success');
  }

  /// check for bip38 encryption
  // 6P valid for rvn?
  if (text.startsWith('6P')) {
    /// prompt for password
    /// decrypt
    /// use key
    return FormatSeed('encrypted bip38', 'failed');
  }

  /// these are placeholders, they must be checked
  var isWIF = [51, 52].contains(text.split('').length);
  var isSeed = text.length == 128;
  var isPrivateKey = text.length == 64;

  //throw Exception('Could not recognize format');
  return FormatSeed('unknown', 'failed');
}

//  /**
//   *
//   * @param importText
//   * @param additionalProperties key-values passed from outside. Used only to set up `masterFingerprint` property for watch-only wallet
//   * @returns {Promise<void>}
//   */
//  WalletImport.processImportText = async (importText, additionalProperties) => {
//    IdleTimerManager.setIdleTimerDisabled(true);
//    // Plan:
//    // 2. check if its RavenWallet (BIP44)
//    // 3. check if its HDLegacyBreadwalletWallet (no BIP, just "m/0")
//    // 3.1 check HD Electrum legacy
//    // 3.2 check if its AEZEED
//    // 4. check if its Segwit WIF (P2SH)
//    // 5. check if its Legacy WIF
//    // 6. check if its address (watch-only wallet)
//    // 7. check if its private key (segwit address P2SH) TODO
//    // 7. check if its private key (legacy address) TODO
//
//    importText = importText.trim();
//
//    if (importText.startsWith('6P')) {
//      let password = false;
//      do {
//        password = await prompt(loc.wallets.looks_like_bip38, loc.wallets.enter_bip38_password, false);
//      } while (!password);
//
//      const decryptedKey = await bip38.decrypt(importText, password);
//
//      if (decryptedKey) {
//        importText = wif.encode(0x80, decryptedKey.privateKey, decryptedKey.compressed);
//      }
//    }
//
//    // is it multisig?
//    try {
//      const ms = new MultisigHDWallet();
//      ms.setSecret(importText);
//      if (ms.getN() > 0 && ms.getM() > 0) {
//        await ms.fetchBalance();
//        return WalletImport._saveWallet(ms);
//      }
//    } catch (e) {
//      console.log(e);
//    }
//
//
//    // trying other wallet types
//    const hd4 = new HDSegwitBech32Wallet();
//    hd4.setSecret(importText);
//    if (hd4.validateMnemonic()) {
//      // OK its a valid BIP39 seed
//
//      if (await hd4.wasEverUsed()) {
//        await hd4.fetchBalance(); // fetching balance for BIP84 only on purpose
//        return WalletImport._saveWallet(hd4);
//      }
//
//      const hd2 = new HDSegwitP2SHWallet();
//      hd2.setSecret(importText);
//      if (await hd2.wasEverUsed()) {
//        return WalletImport._saveWallet(hd2);
//      }
//
//      const hd3 = new RavenWallet();
//      hd3.setSecret(importText);
//      if (await hd3.wasEverUsed()) {
//        return WalletImport._saveWallet(hd3);
//      }
//
//      const hd1 = new HDLegacyBreadwalletWallet();
//      hd1.setSecret(importText);
//      if (await hd1.wasEverUsed()) {
//        return WalletImport._saveWallet(hd1);
//      }
//
//      // no scheme (BIP84/BIP49/BIP44/Bread) was ever used. lets import as default BIP84:
//      return WalletImport._saveWallet(hd4);
//    }
//
//    const segwitWallet = new SegwitP2SHWallet();
//    segwitWallet.setSecret(importText);
//    if (segwitWallet.getAddress()) {
//      // ok its a valid WIF
//
//      const segwitBech32Wallet = new SegwitBech32Wallet();
//      segwitBech32Wallet.setSecret(importText);
//      if (await segwitBech32Wallet.wasEverUsed()) {
//        // yep, its single-address bech32 wallet
//        await segwitBech32Wallet.fetchBalance();
//        return WalletImport._saveWallet(segwitBech32Wallet);
//      }
//
//      if (await segwitWallet.wasEverUsed()) {
//        // yep, its single-address bech32 wallet
//        await segwitWallet.fetchBalance();
//        return WalletImport._saveWallet(segwitWallet);
//      }
//
//      // default wallet is Legacy
//      const legacyWallet = new LegacyWallet();
//      legacyWallet.setSecret(importText);
//      return WalletImport._saveWallet(legacyWallet);
//    }
//
//    // case - WIF is valid, just has uncompressed pubkey
//
//    const legacyWallet = new LegacyWallet();
//    legacyWallet.setSecret(importText);
//    if (legacyWallet.getAddress()) {
//      await legacyWallet.fetchBalance();
//      await legacyWallet.fetchTransactions();
//      return WalletImport._saveWallet(legacyWallet);
//    }
//
//    // if we're here - nope, its not a valid WIF
//
//    try {
//      const hdElectrumSeedLegacy = new HDSegwitElectrumSeedP2WPKHWallet();
//      hdElectrumSeedLegacy.setSecret(importText);
//      if (hdElectrumSeedLegacy.validateMnemonic()) {
//        // not fetching txs or balances, fuck it, yolo, life is too short
//        return WalletImport._saveWallet(hdElectrumSeedLegacy);
//      }
//    } catch (_) {}
//
//    try {
//      const hdElectrumSeedLegacy = new HDLegacyElectrumSeedP2PKHWallet();
//      hdElectrumSeedLegacy.setSecret(importText);
//      if (hdElectrumSeedLegacy.validateMnemonic()) {
//        // not fetching txs or balances, fuck it, yolo, life is too short
//        return WalletImport._saveWallet(hdElectrumSeedLegacy);
//      }
//    } catch (_) {}
//
//    // is it AEZEED?
//    try {
//      const aezeed = new HDAezeedWallet();
//      aezeed.setSecret(importText);
//      if (await aezeed.validateMnemonicAsync()) {
//        // not fetching txs or balances, fuck it, yolo, life is too short
//        return WalletImport._saveWallet(aezeed);
//      } else {
//        // there is a chance that a password is required
//        if (await aezeed.mnemonicInvalidPassword()) {
//          const password = await prompt(loc.wallets.enter_bip38_password, '', false);
//          if (!password) {
//            // no passord is basically cancel whole aezeed import process
//            throw new Error(loc._.bad_password);
//          }
//
//          const mnemonics = importText.split(':')[0];
//          return WalletImport.processImportText(mnemonics + ':' + password);
//        }
//      }
//    } catch (_) {}
//
//    // not valid? maybe its a watch-only address?
//
//    const watchOnly = new WatchOnlyWallet();
//    watchOnly.setSecret(importText);
//    if (watchOnly.valid()) {
//      await watchOnly.fetchBalance();
//      return WalletImport._saveWallet(watchOnly, additionalProperties);
//    }
//
//    // if it is multi-line string, then it is probably SLIP39 wallet
//    // each line - one share
//    if (importText.includes('\n')) {
//      const s1 = new SLIP39SegwitP2SHWallet();
//      s1.setSecret(importText);
//
//      if (s1.validateMnemonic()) {
//        if (await s1.wasEverUsed()) {
//          return WalletImport._saveWallet(s1);
//        }
//
//        const s2 = new SLIP39LegacyP2PKHWallet();
//        s2.setSecret(importText);
//        if (await s2.wasEverUsed()) {
//          return WalletImport._saveWallet(s2);
//        }
//
//        const s3 = new SLIP39SegwitBech32Wallet();
//        s3.setSecret(importText);
//        if (await s3.wasEverUsed()) {
//          return WalletImport._saveWallet(s3);
//        }
//      }
//    }
//
//    // nope?
//
//    // TODO: try a raw private key
//    IdleTimerManager.setIdleTimerDisabled(false);
//    throw new Error('Could not recognize format');
