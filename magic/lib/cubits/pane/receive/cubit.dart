import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/services/wallet/hd.dart';

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

  void populateAddress() {
    Wallet wallet = Wallet(mnemonic: makeMnemonic());
    print('mnemonic: ${wallet.mnemonic}');
    print('entropy: ${wallet.entropy}');
    print('seed: ${wallet.seed}');
    print('seed: ${wallet.subwallet(Blockchain.ravencoinMain).address}');
    update(address: wallet.subwallet(Blockchain.ravencoinMain).address);
  }
}
