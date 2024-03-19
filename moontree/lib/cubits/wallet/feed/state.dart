part of 'cubit.dart';

@immutable
class WalletFeedState with EquatableMixin {
  final Holding currency;
  final List<Holding> assets;
  final bool isSubmitting;
  final WalletFeedState? prior;

  const WalletFeedState({
    this.currency = const Holding.empty(),
    this.assets = const [],
    this.isSubmitting = false,
    this.prior,
  });

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        currency,
        assets,
        isSubmitting,
        prior,
      ];
  WalletFeedState get withoutPrior => WalletFeedState(
        currency: currency,
        assets: assets,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
