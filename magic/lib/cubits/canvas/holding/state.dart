part of 'cubit.dart';

class HoldingState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool send;
  final Holding asset;
  final bool isSubmitting;
  final HoldingState? prior;

  const HoldingState({
    this.active = false,
    this.send = false,
    this.asset = const Holding.empty(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        send,
        asset,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  HoldingState get withoutPrior => HoldingState(
        active: active,
        send: send,
        asset: asset,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;

  String get whole => 'whole'; //asset.coin.().split('.').first;
  String get part => 'part'; //asset.coin.toCommaString().split('.').last;
  String get usd => '\$ usd'; //asset.coin.toCommaString().split('.').last;
}
