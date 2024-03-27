import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:moontree/cubits/mixins.dart';

part 'state.dart';

class AppCubit extends Cubit<AppState>
    with UpdateMixin<AppState> {
  AppCubit() : super(const AppState());
  @override
  String get key => 'app';
  @override
  void reset() => emit(const AppState());
  @override
  void setState(AppState state) => emit(state);

  @override
  void update({
    String? status,
    bool? submitting,
  }) =>
      emit(AppState(
        status: status ?? state.status,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));
}
