import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class MenuCubit extends UpdatableCubit<MenuState> {
  MenuCubit() : super(const MenuState());
  double height = 0;
  @override
  String get key => 'menu';
  @override
  void reset() => emit(const MenuState());
  @override
  void setState(MenuState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {}
  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void update({
    bool? active,
    bool? isSubmitting,
    MenuState? prior,
  }) {
    emit(MenuState(
      active: active ?? state.active,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
