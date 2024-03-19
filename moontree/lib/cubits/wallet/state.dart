part of 'cubit.dart';

class WalletLayerState with EquatableMixin {
  final bool active;

  final bool submitting;
  final WalletLayerState? prior;

  const WalletLayerState({
    this.active = true,
    this.submitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => [
        active,
        submitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  WalletLayerState get withoutPrior => WalletLayerState(
        active: active,
        submitting: submitting,
        prior: null,
      );
}
