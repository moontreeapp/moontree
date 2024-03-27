import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/mixins.dart';

part 'state.dart';

class CanvasCubit extends Cubit<CanvasState> with UpdateHideMixin<CanvasState> {
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
