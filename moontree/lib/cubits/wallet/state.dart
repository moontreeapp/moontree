part of 'cubit.dart';

@immutable
class WalletState with EquatableMixin {
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

  WalletState get withoutPrior => WalletState(
        active: active,
        currency: currency,
        assets: assets,
        child: child,
        isSubmitting: isSubmitting,
        prior: null,
      );

  bool get wasInactive => (prior?.active == null || !prior!.active);
  bool get wasActive => !wasInactive;
}
