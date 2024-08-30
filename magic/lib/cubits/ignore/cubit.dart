import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class IgnoreCubit extends UpdatableCubit<IgnoreState> {
  IgnoreCubit() : super(const IgnoreState());
  @override
  String get key => 'ignore';
  @override
  void reset() => emit(const IgnoreState());
  @override
  void setState(IgnoreState state) => emit(state);
  @override
  void refresh() {}
  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void hide() {
    // TODO: implement hide
  }

  @override
  void update({bool? active}) {
    emit(IgnoreState(active: active ?? state.active));
  }
}
