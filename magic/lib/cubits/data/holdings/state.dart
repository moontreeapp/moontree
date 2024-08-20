part of 'cubit.dart';

class HoldingsState with EquatableMixin, PriorStateMixin {
  final Set<Holding> holdings;
  final int height;
  final bool isSubmitting;
  final HoldingsState? prior;

  const HoldingsState({
    this.holdings = const <Holding>{},
    this.height = 0,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        holdings,
        height,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  HoldingsState get withoutPrior => HoldingsState(
        holdings: holdings,
        height: height,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
