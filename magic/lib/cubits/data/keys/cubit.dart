import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/mnemonic.dart';
import 'package:magic/domain/concepts/storage.dart';
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
    List<String>? mnemonics,
    List<String>? wifs,
    bool? submitting,
  }) {
    syncMnemonics(mnemonics);
    syncKeypairs(wifs);
    //print(mnemonics);
    //try {
    //  print('-----------------------------');
    //  print(master.mnemonicWallets.first.mnemonic);
    //  print(master.mnemonicWallets.first.roots(Blockchain.evrmoreMain));
    //  print(master.mnemonicWallets.first.roots(Blockchain.ravencoinMain));
    //} catch (e) {}
    emit(KeysState(
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
    await dump();
    return true;
  }

  Future<bool> addPrivKey(String privKey) async {
    if (state.wifs.contains(privKey)) return true;
    if (!validatePrivateKey(privKey)) return false;
    update(wifs: [...state.wifs, KeypairWallet.privateKeyToWif(privKey)]);
    await dump();
    return true;
  }

  Future<bool> removeMnemonic(String mnemonic) async {
    if (!state.mnemonics.contains(mnemonic)) return true;
    update(mnemonics: state.mnemonics.where((m) => m != mnemonic).toList());
    await dump();
    return true;
  }

  Future<bool> removeWif(String wif) async {
    if (!state.wifs.contains(wif)) return true;
    update(mnemonics: state.wifs.where((w) => w != wif).toList());
    await dump();
    return true;
  }

  Future<void> load() async {
    update(submitting: true);
    update(
      mnemonics: jsonDecode(
              (await storage.read(key: StorageKey.mnemonics.key())) ?? '[]')
          .cast<String>(),
      wifs: jsonDecode((await storage.read(key: StorageKey.wifs.key())) ?? '[]')
          .cast<String>(),
      submitting: false,
    );
    build();
  }

  Future<void> build() async {
    if (state.mnemonics.isEmpty) {
      update(submitting: true);
      update(
        mnemonics: [makeMnemonic()],
        submitting: false,
      );
      dump();
    }
  }

  Future<void> dump() async {
    storage.write(
        key: StorageKey.mnemonics.key(), value: jsonEncode(state.mnemonics));
    storage.write(key: StorageKey.wifs.key(), value: jsonEncode(state.wifs));
  }

  Future<void> syncMnemonics(List<String>? mnemonics) async {
    if (mnemonics != null) {
      final existingMnemonics =
          master.mnemonicWallets.map((e) => e.mnemonic).toSet();
      final addable = mnemonics.toSet().difference(existingMnemonics);
      final removable = existingMnemonics.difference(mnemonics.toSet());
      master.mnemonicWallets.addAll(
          addable.map((mnemonic) => MnemonicWallet(mnemonic: mnemonic)));
      master.mnemonicWallets.removeWhere(
          (mnemonicWallet) => removable.contains(mnemonicWallet.mnemonic));
    }
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
}
