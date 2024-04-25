import 'package:equatable/equatable.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';

part 'state.dart';

class BalanceCubit extends UpdatableCubit<BalanceState> {
  BalanceCubit() : super(const BalanceState());
  @override
  String get key => 'balance';
  @override
  void reset() => emit(const BalanceState());
  @override
  void setState(BalanceState state) => emit(state);
  @override
  void hide() => update(active: false);
  @override
  void refresh() {
    update(isSubmitting: false);
    update(isSubmitting: true);
  }

  @override
  void activate() => update(active: true);
  @override
  void deactivate() => update(active: false);
  @override
  void update({
    bool? active,
    bool? initialized,
    Fiat? portfolioValue,
    bool? isSubmitting,
    BalanceState? prior,
  }) {
    emit(BalanceState(
      active: active ?? state.active,
      initialized: initialized ?? state.initialized,
      portfolioValue: portfolioValue ?? state.portfolioValue,
      isSubmitting: isSubmitting ?? state.isSubmitting,
      prior: prior ?? state.withoutPrior,
    ));
  }
}
