part of 'cubit.dart';

enum HoldingSection {
  none,
  send,
  receive,
  swap,
  transaction;
}

class HoldingState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final HoldingSection section;
  final Holding asset;
  final bool isSubmitting;
  final HoldingState? prior;

  const HoldingState({
    this.active = false,
    this.section = HoldingSection.none,
    this.asset = const Holding.empty(),
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        section,
        asset,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  HoldingState get withoutPrior => HoldingState(
        active: active,
        section: section,
        asset: asset,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
  bool get onHistory => section == HoldingSection.none;

  String get whole => 'whole'; //asset.coin.().split('.').first;
  String get part => 'part'; //asset.coin.toCommaString().split('.').last;
  String get usd => '\$ usd'; //asset.coin.toCommaString().split('.').last;
}
