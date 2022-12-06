// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:moontree_utils/moontree_utils.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/hex.dart' as hex;

import 'package:wallet_utils/wallet_utils.dart';

class CipherService {
  /// used in decrypting backups - we don't know what cipher it was encrypted with... we could save it...
  List<CipherType> get allCipherTypes => [CipherType.aes, CipherType.none];

  int gracePeriod = 60 * 1;
  DateTime? lastLoginTime;
  DateTime loginTime() => lastLoginTime = DateTime.now();

  bool get canAskForPasswordNow => lastLoginTime == null
      ? true
      : DateTime.now().difference(lastLoginTime!).inSeconds >= gracePeriod;

  CipherType get latestCipherType => services.password.exist
      ? pros.passwords.current!.saltedHash == ''
          ? CipherType.none
          : CipherType.aes
      : CipherType.none;

  @override
  String toString() => 'latestCipherType: ${latestCipherType.name}';

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwordId: pros.passwords.maxPasswordId);

  CipherUpdate get noneCipherUpdate =>
      CipherUpdate(CipherType.none, passwordId: pros.passwords.maxPasswordId);

  Cipher? get currentCipherBase =>
      pros.ciphers.primaryIndex.getOneByCipherUpdate(currentCipherUpdate);

  CipherBase? get currentCipher => currentCipherBase?.cipher;

  /// make sure all wallets are on the latest ciphertype and password
  Future<void> updateWallets({
    CipherBase? cipher,
    Future<void> Function(Secret secret)? saveSecret,
  }) async {
    List<Wallet> records = <Wallet>[];
    for (Wallet wallet in pros.wallets.records) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          records.add(await reencryptLeaderWallet(wallet, cipher, saveSecret));
        } else if (wallet is SingleWallet) {
          records.add(await reencryptSingleWallet(wallet, cipher, saveSecret));
        }
      }
    }
    await pros.wallets.saveAll(records);

    /// completed successfully
    assert(services.wallet.getPreviousCipherUpdates.isEmpty);
  }

  Future<LeaderWallet> reencryptLeaderWallet(
    LeaderWallet wallet, [
    CipherBase? cipher,
    Future<void> Function(Secret secret)? saveSecret,
  ]) async {
    final String encryptedEntropy =
        hex.encrypt(await wallet.entropy, cipher ?? currentCipher!);
    final Uint8List seed = await wallet.seed;
    final String newId = HDWallet.fromSeed(seed).pubKey;
    assert(wallet.id == newId);
    if (saveSecret != null) {
      await saveSecret(Secret(
          secret: encryptedEntropy,
          secretType: SecretType.encryptedEntropy,
          pubkey: newId));
    }
    return LeaderWallet(
      id: newId,
      encryptedEntropy: '',
      cipherUpdate: currentCipherUpdate,
      name: wallet.name,
      backedUp: wallet.backedUp,
      skipHistory: wallet.skipHistory,
      seed: seed, // necessary?
      getEntropy: wallet.getEntropy,
    );
  }

  Future<SingleWallet> reencryptSingleWallet(
    SingleWallet wallet, [
    CipherBase? cipher,
    Future<void> Function(Secret secret)? saveSecret,
  ]) async {
    EncryptedWIF reencrypt = EncryptedWIF.fromWIF(
      await wallet.wif,
      cipher ?? currentCipher!,
    );
    assert(wallet.id == reencrypt.walletId);
    if (saveSecret != null) {
      await saveSecret(Secret(
          secret: reencrypt.secret,
          secretType: SecretType.encryptedWif,
          pubkey: reencrypt.walletId));
    }
    return SingleWallet(
      id: reencrypt.walletId,
      encryptedWIF: reencrypt.encryptedSecret,
      cipherUpdate: currentCipherUpdate,
      skipHistory: wallet.skipHistory,
      name: wallet.name,
    );
  }

  void initCiphers({
    Uint8List? password,
    String? altPassword,
    Uint8List? salt,
    String? altSalt,
    Set<CipherUpdate>? currentCipherUpdates,
  }) {
    password = getPassword(password: password, altPassword: altPassword);
    salt = getSalt(salt: salt, altSalt: altSalt);
    for (CipherUpdate currentCipherUpdate
        in currentCipherUpdates ?? _cipherUpdates) {
      pros.ciphers.registerCipher(currentCipherUpdate, password, salt);
    }
  }

  CipherBase updatePassword({
    Uint8List? password,
    String? altPassword,
    Uint8List? salt,
    String? altSalt,
    CipherType? latest,
  }) {
    latest = latest ?? latestCipherType;
    password = getPassword(password: password, altPassword: altPassword);
    salt = getSalt(salt: salt, altSalt: altSalt);
    return pros.ciphers.registerCipher(
      password == []
          ? CipherUpdate(CipherType.none,
              passwordId: pros.passwords.maxPasswordId)
          : currentCipherUpdate,
      password,
      salt,
    );
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses and that are not the current one
  Future<void> cleanupCiphers() async {
    await pros.ciphers.removeAll(pros.ciphers.records.where(
        (Cipher cipher) => !_cipherUpdates.contains(cipher.cipherUpdate)));

    if (pros.ciphers.records.length > 2) {
      // in theory a wallet is not updated ... error?
      print('more ciphers than default and password - that is weird');
    }
  }

  Set<CipherUpdate> get _cipherUpdates =>
      (services.wallet.getAllCipherUpdates.toList() + [currentCipherUpdate])
          .toSet();

  Uint8List getPassword({Uint8List? password, String? altPassword}) {
    password ??
        altPassword ??
        (() => throw OneOfMultipleMissing(
            'password or altPassword required to initialize pros.ciphers.'))();
    return password ?? Uint8List.fromList(altPassword!.codeUnits);
  }

  Uint8List getSalt({Uint8List? salt, String? altSalt}) {
    salt ??
        altSalt ??
        (() => throw OneOfMultipleMissing(
            'salt or altSalt required to initialize pros.ciphers.'))();
    return salt ?? Uint8List.fromList(altSalt!.codeUnits);
  }
}
