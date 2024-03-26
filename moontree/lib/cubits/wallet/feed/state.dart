part of 'cubit.dart';

@immutable
class WalletFeedState with EquatableMixin {
  final bool active;
  final Holding currency;
  final List<Holding> assets;
  final bool isSubmitting;
  final WalletFeedState? prior;

  const WalletFeedState({
    this.active = false,
    this.currency = const Holding.empty(),
    this.assets = const [],
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
        isSubmitting,
        prior,
      ];
  WalletFeedState get withoutPrior => WalletFeedState(
        active: active,
        currency: currency,
        assets: assets,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
