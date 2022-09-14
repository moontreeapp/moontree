import 'dart:typed_data';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/utilities/hex.dart' as hex;

import 'package:ravencoin_wallet/ravencoin_wallet.dart';

class CipherService {
  /// used in decrypting backups - we don't know what cipher it was encrypted with... we could save it...
  List<CipherType> get allCipherTypes => [CipherType.AES, CipherType.None];

  int gracePeriod = 60 * 1;
  DateTime? lastLoginTime;
  DateTime loginTime() => lastLoginTime = DateTime.now();

  bool get canAskForPasswordNow => lastLoginTime != null
      ? DateTime.now().difference(lastLoginTime!).inSeconds >= gracePeriod
      : true;

  CipherType get latestCipherType => services.password.exist
      ? pros.passwords.current!.saltedHash == ''
          ? CipherType.None
          : CipherType.AES
      : CipherType.None;

  @override
  String toString() => 'latestCipherType: ${latestCipherType.enumString}';

  CipherUpdate get currentCipherUpdate =>
      CipherUpdate(latestCipherType, passwordId: pros.passwords.maxPasswordId);

  CipherUpdate get noneCipherUpdate =>
      CipherUpdate(CipherType.None, passwordId: pros.passwords.maxPasswordId);

  Cipher? get currentCipherBase =>
      pros.ciphers.primaryIndex.getOne(currentCipherUpdate);

  CipherBase? get currentCipher => currentCipherBase?.cipher;

  /// make sure all wallets are on the latest ciphertype and password
  Future updateWallets({CipherBase? cipher}) async {
    var records = <Wallet>[];
    for (var wallet in pros.wallets.records) {
      if (wallet.cipherUpdate != currentCipherUpdate) {
        if (wallet is LeaderWallet) {
          records.add(reencryptLeaderWallet(wallet, cipher));
        } else if (wallet is SingleWallet) {
          records.add(reencryptSingleWallet(wallet, cipher));
        }
      }
    }
    await pros.wallets.saveAll(records);

    /// completed successfully
    assert(services.wallet.getPreviousCipherUpdates.isEmpty);
  }

  LeaderWallet reencryptLeaderWallet(
    LeaderWallet wallet, [
    CipherBase? cipher,
  ]) {
    final encrypted_entropy =
        hex.encrypt(wallet.entropy, cipher ?? currentCipher!);
    final newId = HDWallet.fromSeed(wallet.seed).pubKey;
    assert(wallet.id == newId);
    return LeaderWallet(
      id: newId,
      encryptedEntropy: encrypted_entropy,
      cipherUpdate: currentCipherUpdate,
      name: wallet.name,
      backedUp: wallet.backedUp,
      skipHistory: wallet.skipHistory,
      seed: wallet.seed, // necessary?
    );
  }

  SingleWallet reencryptSingleWallet(SingleWallet wallet,
      [CipherBase? cipher]) {
    var reencrypt = EncryptedWIF.fromWIF(
      EncryptedWIF(wallet.encrypted, wallet.cipher!).wif,
      cipher ?? currentCipher!,
    );
    assert(wallet.id == reencrypt.walletId);
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
    Set<CipherUpdate>? currentCipherUpdates,
  }) {
    password = getPassword(password: password, altPassword: altPassword);
    for (var currentCipherUpdate in currentCipherUpdates ?? _cipherUpdates) {
      pros.ciphers.registerCipher(currentCipherUpdate, password);
    }
  }

  CipherBase updatePassword({
    Uint8List? password,
    String? altPassword,
    CipherType? latest,
  }) {
    latest = latest ?? latestCipherType;
    password = getPassword(password: password, altPassword: altPassword);
    return pros.ciphers.registerCipher(
      password == []
          ? CipherUpdate(CipherType.None,
              passwordId: pros.passwords.maxPasswordId)
          : currentCipherUpdate,
      password,
    );
  }

  /// after wallets are updated or verified to be up to date
  /// remove all ciphers that no wallet uses and that are not the current one
  void cleanupCiphers() {
    pros.ciphers.removeAll(pros.ciphers.records
        .where((cipher) => !_cipherUpdates.contains(cipher.cipherUpdate)));

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
}
