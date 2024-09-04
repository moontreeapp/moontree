import 'package:equatable/equatable.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/blockchain/exposure.dart';
import 'package:magic/domain/wallet/wallets.dart';
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
    //print('address: ${address}');
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
    DerivationWallet? mnemonicWallet,
    int? overrideIndex,
  }) async {
    if (overrideIndex != null) return overrideIndex;
    if (mnemonicWallet != null) {
      return (await ReceiveCall.fromDerivationWallet(
        blockchain: blockchain,
        mnemonicWallet: mnemonicWallet,
        exposure: exposure,
      ).call())
          .value;
    }
    return 20;
  }

  Future<void> populateAddresses(
    Blockchain blockchain, {
    int? overrideIndex,
  }) async {
    final seedWallet =
        cubits.keys.master.derivationWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.derivationWallets.first.seedWallet(blockchain).derive({
        Exposure.internal: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.internal,
            mnemonicWallet: cubits.keys.master.derivationWallets.first,
            overrideIndex: overrideIndex),
        Exposure.external: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.external,
            mnemonicWallet: cubits.keys.master.derivationWallets.first,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.derivationWallets.first
          .seedWallet(blockchain)
          .derive();
    }
    update(
        address: cubits.keys.master.derivationWallets.first
            .seedWallet(blockchain)
            .internals
            .lastOrNull
            ?.address);
  }

  /// derive all addresses for all blockchains
  /// use derivationWallets if they exist, else use xPubWallets
  Future<void> deriveAll(List<Blockchain> blockchains) async {
    for (var blockchain in blockchains) {
      for (var mnemonicWallet in cubits.keys.master.derivationWallets) {
        mnemonicWallet.seedWallet(blockchain).derive({
          Exposure.internal: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.internal,
            mnemonicWallet: mnemonicWallet,
          ),
          Exposure.external: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.external,
            mnemonicWallet: mnemonicWallet,
          ),
        });
      }
    }
  }

  Future<void> populateReceiveAddress(
    Blockchain blockchain, {
    int? overrideIndex,
  }) async {
    final seedWallet =
        cubits.keys.master.derivationWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.derivationWallets.first.seedWallet(blockchain).derive({
        Exposure.external: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.external,
            mnemonicWallet: cubits.keys.master.derivationWallets.first,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.derivationWallets.first
          .seedWallet(blockchain)
          .derive({Exposure.external: 0});
    }
    update(
        address: cubits.keys.master.derivationWallets.first
            .seedWallet(blockchain)
            .externals
            .lastOrNull
            ?.address);
  }

  Future<String> populateChangeAddress(
    Blockchain blockchain, {
    int? overrideIndex,
  }) async {
    final seedWallet =
        cubits.keys.master.derivationWallets.first.seedWallet(blockchain);
    if (seedWallet.highestIndex.isEmpty) {
      cubits.keys.master.derivationWallets.first.seedWallet(blockchain).derive({
        Exposure.internal: await _getIndex(
            blockchain: blockchain,
            exposure: Exposure.internal,
            mnemonicWallet: cubits.keys.master.derivationWallets.first,
            overrideIndex: overrideIndex),
      });
    } else {
      cubits.keys.master.derivationWallets.first
          .seedWallet(blockchain)
          .derive({Exposure.internal: 0});
    }
    update(
        changeAddress: cubits.keys.master.derivationWallets.first
            .seedWallet(blockchain)
            .internals
            .last
            .address);
    return state.changeAddress;
  }
}
