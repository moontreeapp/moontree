import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/side.dart';

part 'state.dart';

class PanelCubit extends Cubit<PanelState> with UpdateSectionMixin<PanelState> {
  PanelCubit() : super(const PanelState());
  @override
  void reset() => emit(const PanelState());
  @override
  void setState(PanelState state) => emit(state);
  void refresh() => update(isSubmitting: true);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    Widget Function(ScrollController)? child,
    Side? transition,
    bool? isSubmitting,
  }) {
    emit(PanelState(
      active: active ?? state.active,
      child: child ?? state.child,
      transition: transition ?? state.transition,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: state.withoutPrior,
    ));
  }
}
