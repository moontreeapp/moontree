import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/services/services.dart';
part 'state.dart';

class KeysCubit extends UpdatableCubit<KeysState> {
  KeysCubit() : super(KeysState.empty());
  @override
  String get key => 'keys';
  @override
  void reset() => emit(KeysState.empty());
  @override
  void setState(KeysState state) => emit(state);
  @override
  void hide() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void refresh() {
    update(submitting: false);
    update(submitting: true);
  }

  @override
  void update({
    List<String>? mnemonics,
    List<String>? wifs,
    bool? submitting,
  }) =>
      emit(KeysState(
        mnemonics: mnemonics ?? state.mnemonics,
        wifs: wifs ?? state.wifs,
        submitting: submitting ?? state.submitting,
        prior: state.withoutPrior,
      ));

  Future<void> load() async {
    update(submitting: true);
    update(
      mnemonics: jsonDecode((await storage.read(key: 'mnemonics')) ?? '[]')
          .cast<String>(),
      wifs:
          jsonDecode((await storage.read(key: 'wifs')) ?? '[]').cast<String>(),
      submitting: false,
    );
  }

  Future<void> dump() async {
    storage.write(key: 'mnemonics', value: jsonEncode(state.mnemonics));
    storage.write(key: 'wifs', value: jsonEncode(state.wifs));
  }
}
