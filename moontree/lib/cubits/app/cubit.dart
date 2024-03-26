import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/utilities.dart';

part 'state.dart';

class AppLayerCubit extends Cubit<AppLayerState>
    with UpdateMixin<AppLayerState> {
  AppLayerCubit() : super(const AppLayerState());
  @override
  String get key => 'app';
  @override
  void reset() => emit(const AppLayerState());
  @override
  void setState(AppLayerState state) => emit(state);

  @override
  void update({
    String? status,
    bool? submitting,
  }) =>
      emit(AppLayerState(
        status: status ?? state.status,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));
}
