import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class SwapCubit extends Cubit<SwapState> with UpdateHideMixin<SwapState> {
  SwapCubit() : super(const SwapState());
  double height = 0;
  @override
  String get key => 'swap';
  @override
  void reset() => emit(const SwapState());
  @override
  void setState(SwapState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    String? asset,
    String? chain,
    String? address,
    bool? isSubmitting,
    SwapState? prior,
  }) {
    emit(SwapState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      chain: chain ?? state.chain,
      address: address ?? state.address,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
