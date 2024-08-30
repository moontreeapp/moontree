import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';

part 'state.dart';

class CanvasCubit extends UpdatableCubit<CanvasState> {
  CanvasCubit() : super(const CanvasState());
  double height = 0;
  @override
  String get key => 'canvas';
  @override
  void reset() => emit(const CanvasState());
  @override
  void setState(CanvasState state) => emit(state);
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
    CanvasState? prior,
  }) {
    emit(CanvasState(
      active: active ?? state.active,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
