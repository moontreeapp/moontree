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
    String? changeAddress,
    bool? isSubmitting,
    ReceiveState? prior,
  }) {
    print('address: ${address}');
    //print('address: ${address?.h160AsString(Blockchain.evrmoreMain)}');

    emit(ReceiveState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      chain: chain ?? state.chain,
      address: address ?? state.address,
      changeAddress: changeAddress ?? state.changeAddress,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }

  Future<int> _getIndex({
    required Blockchain blockchain,
    required Exposure exposure,
    int? overrideIndex,
  }) async =>
      overrideIndex ??
      (await ReceiveCall(
        blockchain: blockchain,
        mnemonicWallet: cubits.keys.master.mnemonicWallets.first,
        exposure: exposure,
      ).call())
          .value;

  Future<void> populateAddresses(Blockchain blockchain,
      {int? overrideIndex}) async {
    final seedWallet =
        cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain).derive({
        Exposure.internal: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.internal,
            overrideIndex: overrideIndex),
        Exposure.external: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.external,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain).derive();
    }
    update(
        address: cubits.keys.master.mnemonicWallets.first
            .seedWallet(blockchain)
            .internals
            .lastOrNull
            ?.address);
  }

  Future<void> populateReceiveAddress(Blockchain blockchain,
      {int? overrideIndex}) async {
    final seedWallet =
        cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain).derive({
        Exposure.external: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.external,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.mnemonicWallets.first
          .seedWallet(blockchain)
          .derive({Exposure.external: 0});
    }
    update(
        address: cubits.keys.master.mnemonicWallets.first
            .seedWallet(blockchain)
            .externals
            .last
            .address);
  }

  Future<String> populateChangeAddress(Blockchain blockchain,
      {int? overrideIndex}) async {
    final seedWallet =
        cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.mnemonicWallets.first.seedWallet(blockchain).derive({
        Exposure.internal: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.internal,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.mnemonicWallets.first
          .seedWallet(blockchain)
          .derive({Exposure.internal: 0});
    }
    update(
        changeAddress: cubits.keys.master.mnemonicWallets.first
            .seedWallet(blockchain)
            .internals
            .last
            .address);
    return state.changeAddress;
  }
}
