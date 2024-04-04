import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';

part 'state.dart';

class SendCubit extends Cubit<SendState> with UpdateHideMixin<SendState> {
  SendCubit() : super(const SendState());
  double height = 0;
  @override
  String get key => 'send';
  @override
  void reset() => emit(const SendState());
  @override
  void setState(SendState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    String? asset,
    double? amount,
    bool? isSubmitting,
    SendState? prior,
  }) {
    emit(SendState(
      active: active ?? state.active,
      asset: asset ?? state.asset,
      amount: amount ?? state.amount,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
