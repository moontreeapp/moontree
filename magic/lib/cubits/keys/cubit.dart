import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class KeysCubit extends UpdatableCubit<KeysState> {
  KeysCubit() : super(const KeysState());
  @override
  String get key => 'app';
  @override
  void reset() => emit(const KeysState());
  @override
  void setState(KeysState state) => emit(state);
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
    String? key,
    bool? submitting,
  }) =>
      emit(KeysState(
        key: key ?? state.key,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));

  void setKey(String key) => update(key: 'derivation key');
}
