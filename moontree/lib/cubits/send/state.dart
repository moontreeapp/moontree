part of 'cubit.dart';

class SendState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final String asset; // TODO: use domain object
  final double amount; // TODO: use domain object
  final bool isSubmitting;
  final SendState? prior;

  const SendState({
    this.active = false,
    this.asset = '',
    this.amount = 0,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        asset,
        amount,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  SendState get withoutPrior => SendState(
        active: active,
        asset: asset,
        amount: amount,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
