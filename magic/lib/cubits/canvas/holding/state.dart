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
  final Holding holding;
  final TransactionDisplay? transaction;
  final bool isSubmitting;
  final HoldingState? prior;

  const HoldingState({
    this.active = false,
    this.section = HoldingSection.none,
    this.holding = const Holding.empty(),
    this.transaction,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        section,
        holding,
        transaction,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  HoldingState get withoutPrior => HoldingState(
        active: active,
        section: section,
        holding: holding,
        transaction: transaction,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
  bool get onHistory => section == HoldingSection.none;

  String get whole => holding.coin.humanString().split('.').first;
  String get part => holding.coin.humanString().split('.').last != '0'
      ? holding.coin.humanString().split('.').last
      : '';
  String get usd => '\$ ${holding.fiat}';
  String get wholeTransaction =>
      transaction?.coin.humanString().split('.').first ?? '0';
  String get partTransaction =>
      transaction?.coin.humanString().split('.').last != '0'
          ? transaction?.coin.humanString().split('.').last ?? ''
          : '';
  String get usdTransaction => '\$ ${transaction?.fiat ?? '-'}';
}
