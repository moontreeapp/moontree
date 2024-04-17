import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/holding.dart';

part 'state.dart';

class HoldingCubit extends Cubit<HoldingState>
    with UpdateHideMixin<HoldingState> {
  HoldingCubit() : super(const HoldingState());
  double height = 0;
  @override
  String get key => 'holding';
  @override
  void reset() => emit(const HoldingState());
  @override
  void setState(HoldingState state) => emit(state);
  @override
  void hide() => update(active: false);

  @override
  void update({
    bool? active,
    HoldingSection? section,
    Holding? asset,
    bool? isSubmitting,
    HoldingState? prior,
  }) {
    emit(HoldingState(
      active: active ?? state.active,
      section: section ?? state.section,
      asset: asset ?? state.asset,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
