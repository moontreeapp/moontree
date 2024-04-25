import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class AppCubit extends UpdatableCubit<AppState> {
  AppCubit() : super(const AppState());
  @override
  String get key => 'app';
  @override
  void reset() => emit(const AppState());
  @override
  void setState(AppState state) => emit(state);
  @override
  void refresh() {
    update(submitting: false);
    update(submitting: true);
  }

  @override
  void hide() {
    // TODO: implement hide
  }
  @override
  void activate() => update();
  @override
  void deactivate() => update();

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
