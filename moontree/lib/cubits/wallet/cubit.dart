import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class WalletLayerCubit extends Cubit<WalletLayerState>
    with UpdateSectionMixin<WalletLayerState> {
  WalletLayerCubit() : super(const WalletLayerState());
  @override
  String get key => 'wallet';
  @override
  void reset() => emit(const WalletLayerState());
  @override
  void setState(WalletLayerState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    bool? submitting,
  }) =>
      emit(WalletLayerState(
        active: active ?? state.active,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));
}
