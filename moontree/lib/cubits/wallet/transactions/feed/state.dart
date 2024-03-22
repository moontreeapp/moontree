part of 'cubit.dart';

@immutable
class TransactionsFeedState with EquatableMixin {
  final Holding currency;
  final List<Holding> assets;
  final bool isSubmitting;
  final TransactionsFeedState? prior;

  const TransactionsFeedState({
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
  TransactionsFeedState get withoutPrior => TransactionsFeedState(
        currency: currency,
        assets: assets,
        isSubmitting: isSubmitting,
        prior: null,
      );
}
