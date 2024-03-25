import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class TransactionsLayerCubit extends Cubit<TransactionsLayerState>
    with UpdateSectionMixin<TransactionsLayerState> {
  TransactionsLayerCubit() : super(const TransactionsLayerState());
  @override
  String get key => 'transactions';
  @override
  void reset() => emit(const TransactionsLayerState());
  @override
  void setState(TransactionsLayerState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    bool? submitting,
  }) =>
      emit(TransactionsLayerState(
        active: active ?? state.active,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));
}
