import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class TransactionCubit extends Cubit<TransactionState>
    with UpdateHideMixin<TransactionState> {
  TransactionCubit() : super(const TransactionState());
  double height = 0;
  @override
  String get key => 'transaction';
  @override
  void reset() => emit(const TransactionState());
  @override
  void setState(TransactionState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    String? asset,
    String? chain,
    String? address,
    bool? isSubmitting,
    TransactionState? prior,
  }) {
    emit(TransactionState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      chain: chain ?? state.chain,
      address: address ?? state.address,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
