import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/services/calls/receive.dart';

part 'state.dart';

class ReceiveCubit extends UpdatableCubit<ReceiveState> {
  ReceiveCubit() : super(const ReceiveState());
  double height = 0;
  @override
  String get key => 'receive';
  @override
  void reset() => emit(const ReceiveState());
  @override
  void setState(ReceiveState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);

  @override
  void update({
    bool? active,
    String? asset,
    String? chain,
    String? address,
    bool? isSubmitting,
    ReceiveState? prior,
  }) {
    emit(ReceiveState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      chain: chain ?? state.chain,
      address: address ?? state.address,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Future<void> populateAddress() async {
    //MnemonicWallet wallet = MnemonicWallet(mnemonic: makeMnemonic());
    //print('mnemonic: ${wallet.mnemonic}');
    //print('entropy: ${wallet.entropy}');
    //print('seed: ${wallet.seed}');
    //print(
    //    'seed: ${wallet.seedWallet(Blockchain.ravencoinMain).hdWallet.address}');
    //update(
    //    address: wallet.seedWallet(Blockchain.ravencoinMain).hdWallet.address);

    final seedWallet = cubits.keys.master.mnemonicWallets.first
        .seedWallet(Blockchain.ravencoinMain);
    if (seedWallet.highestIndex.isEmpty) {
      final indexMap = {
        Exposure.internal: (await ReceiveCall(
          blockchain: Blockchain.evrmoreMain,
          mnemonicWallet: cubits.keys.master.mnemonicWallets.first,
          exposure: Exposure.internal,
        ).call())
            .value,
        Exposure.external: (await ReceiveCall(
          blockchain: Blockchain.evrmoreMain,
          mnemonicWallet: cubits.keys.master.mnemonicWallets.first,
          exposure: Exposure.external,
        ).call())
            .value,
      };
      cubits.keys.master.mnemonicWallets.first
          .seedWallet(Blockchain.ravencoinMain)
          .derive(indexMap);
    } else {
      cubits.keys.master.mnemonicWallets.first
          .seedWallet(Blockchain.ravencoinMain)
          .derive();
    }
    update(
        // not right this is a seed wallet, not a derivative wallet:
        //  address: cubits.keys.master.mnemonicWallets.first
        //      .seedWallet(Blockchain.ravencoinMain)
        //      .hdWallet
        //      .address);
        address: cubits.keys.master.mnemonicWallets.first
            .seedWallet(Blockchain.ravencoinMain)
            .externals
            .last
            .address);
  }
}
