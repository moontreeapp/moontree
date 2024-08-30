import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class FadeCubit extends UpdatableCubit<FadeState> {
  FadeCubit() : super(const FadeState());
  @override
  String get key => 'ignore';
  @override
  void reset() => emit(const FadeState());
  @override
  void setState(FadeState state) => emit(state);
  @override
  void hide() {
    // TODO: implement hide
  }

  @override
  void refresh() {}
  @override
  void activate() => update();
  @override
  void deactivate() => update();
  @override
  void update({FadeEvent? fade}) {
    emit(FadeState(fade: fade ?? state.fade));
  }
}
