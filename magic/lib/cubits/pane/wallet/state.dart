part of 'cubit.dart';

@immutable
class WalletState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final Holding currency;
  final List<Holding> assets;
  final Widget child;
  final bool isSubmitting;
  final WalletState? prior;

  const WalletState({
    this.active = false,
    this.currency = const Holding.empty(),
    this.assets = const [],
    this.child = const SizedBox.shrink(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        active,
        currency,
        assets,
        child,
        isSubmitting,
        prior,
      ];

  @override
  WalletState get withoutPrior => WalletState(
        active: active,
        currency: currency,
        assets: assets,
        child: child,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
