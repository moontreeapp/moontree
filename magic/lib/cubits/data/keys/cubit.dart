import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/mnemonic.dart';
import 'package:magic/domain/storage/secure.dart';
import 'package:magic/domain/wallet/utils.dart';
import 'package:magic/domain/wallet/wallets.dart';
import 'package:magic/services/services.dart';
part 'state.dart';

class KeysCubit extends UpdatableCubit<KeysState> {
  MasterWallet master = MasterWallet();

  KeysCubit() : super(KeysState.empty());
  @override
  String get key => 'keys';
  @override
  void reset() => emit(KeysState.empty());
  @override
  void setState(KeysState state) => emit(state);
  @override
  void hide() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void refresh() {
    update(submitting: false);
    update(submitting: true);
  }

  @override
  void update({
    List<Map<String, String>>? xpubs,
    List<String>? mnemonics,
    List<String>? wifs,
    bool? submitting,
  }) {
    syncMnemonics(mnemonics);
    syncKeypairs(wifs);
    syncXPubs(xpubs);
    //print(mnemonics);
    //try {
    //  print('-----------------------------');
    //  print(master.derivationWallets.first.mnemonic);
    //  print(master.derivationWallets.first.roots(Blockchain.evrmoreMain));
    //  print(master.derivationWallets.first.roots(Blockchain.ravencoinMain));
    //} catch (e) {}
    emit(KeysState(
      xpubs: xpubs ?? state.xpubs,
      mnemonics: mnemonics ?? state.mnemonics,
      wifs: wifs ?? state.wifs,
      submitting: submitting ?? state.submitting,
      prior: state.withoutPrior,
    ));
  }

  Future<bool> addMnemonic(String mnemonic) async {
    if (state.mnemonics.contains(mnemonic)) return true;
    if (!validateMnemonic(mnemonic)) return false;
    update(mnemonics: [...state.mnemonics, mnemonic]);
    await saveSecrets();
    return true;
  }

  Future<bool> addPrivKey(String privKey) async {
    if (state.wifs.contains(privKey)) return true;
    if (!validatePrivateKey(privKey)) return false;
    update(wifs: [...state.wifs, KeypairWallet.privateKeyToWif(privKey)]);
    await saveSecrets();
    return true;
  }

  Future<bool> removeMnemonic(String mnemonic) async {
    if (!state.mnemonics.contains(mnemonic)) return true;
    update(mnemonics: state.mnemonics.where((m) => m != mnemonic).toList());
    await saveSecrets();
    return true;
  }

  Future<bool> removeWif(String wif) async {
    if (!state.wifs.contains(wif)) return true;
    update(mnemonics: state.wifs.where((w) => w != wif).toList());
    await saveSecrets();
    return true;
  }

  Future<void> loadXPubs() async {
    final List<dynamic> rawXpubs = jsonDecode(
        ((await storage()).read(key: StorageKey.xpubs.key())) ?? '[]');
    final List<Map<String, String>> xpubs = rawXpubs.map((entry) {
      return Map<String, String>.from(entry);
    }).toList();
    if (xpubs.isNotEmpty && xpubs != [{}]) {
      update(submitting: true);
      update(
        xpubs: xpubs,
        submitting: false,
      );
    } else {
      loadSecrets(onExisting: saveXPubs);
    }
  }

  Future<void> loadSecrets({Future<void> Function()? onExisting}) async {
    update(submitting: true);
    update(
      mnemonics: jsonDecode((await secureStorage.read(
                  key: SecureStorageKey.mnemonics.key())) ??
              '[]')
          .cast<String>(),
      wifs: jsonDecode(
              (await secureStorage.read(key: SecureStorageKey.wifs.key())) ??
                  '[]')
          .cast<String>(),
      submitting: false,
    );
    build(onExisting: onExisting);
  }

  Future<void> build({Future<void> Function()? onExisting}) async {
    if (state.mnemonics.isEmpty) {
      update(submitting: true);
      update(
        mnemonics: [makeMnemonic()],
        submitting: false,
      );
      saveSecrets();
    } else {
      // for zedge case - we should never have mnemonics on disk without xpubs
      // but if for some wild reason we do, we should save the xpubs now.
      if (onExisting != null) {
        await onExisting();
      }
    }
  }

  /// we don't really need to sync with xpubs because we always add them all at
  /// once (on startup). If we import a wallet, we switch over to using
  /// privkeys, and then rewrite all the xpubs to disk again.
  Future<void> syncXPubs(List<Map<String, String>>? xpubs) async {
    if (xpubs != null) {
      master.derivationWallets.addAll(xpubs
          .map((blockchainXpub) => DerivationWallet.fromXpubs(blockchainXpub)));
    }
  }

  Future<void> syncMnemonics(List<String>? mnemonics) async {
    if (mnemonics != null) {
      final existingMnemonics =
          master.derivationWallets.map((e) => e.mnemonic).toSet();
      final addable = mnemonics.toSet().difference(existingMnemonics);
      final removable = existingMnemonics.difference(mnemonics.toSet());
      master.derivationWallets.addAll(
          addable.map((mnemonic) => DerivationWallet(mnemonic: mnemonic)));
      master.derivationWallets.removeWhere(
          (derivationWallet) => removable.contains(derivationWallet.mnemonic));
    }
    //for (final blockchain in Blockchain.values) {
    //  for (final derivationWallet in master.derivationWallets) {
    //    derivationWallet.pubkey(blockchain);
    //  }
    //}
  }

  Future<void> syncKeypairs(List<String>? wifs) async {
    if (wifs != null) {
      final existingWifs = master.keypairWallets.map((e) => e.wif).toSet();
      final addable = wifs.toSet().difference(existingWifs);
      final removable = existingWifs.difference(wifs.toSet());
      master.keypairWallets
          .addAll(addable.map((wif) => KeypairWallet(wif: wif)));
      master.keypairWallets.removeWhere(
          (keypairWallet) => removable.contains(keypairWallet.wif));
    }
  }

  Future<void> saveSecrets() async {
    secureStorage.write(
        key: SecureStorageKey.mnemonics.key(),
        value: jsonEncode(state.mnemonics));
    secureStorage.write(
        key: SecureStorageKey.wifs.key(), value: jsonEncode(state.wifs));
    // every time we save secrets we save xpubs because the secrets are our
    // source of truth for the xpubs:
    saveXPubs();
  }

  void ensureSeedWalletsExist() {
    for (final blockcahin in Blockchain.mainnets) {
      for (final derivationWallet in master.derivationWallets) {
        derivationWallet.seedWallet(blockcahin);
      }
    }
  }

  Future<void> saveXPubs() async {
    ensureSeedWalletsExist();
    (await storage()).writeKey(
      key: StorageKey.xpubs,
      value: jsonEncode(
          master.derivationWallets.map((wallet) => wallet.asXPubMap).toList()),
    );
  }
}
