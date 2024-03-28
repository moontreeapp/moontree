part of 'cubit.dart';

class HoldingState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool send;
  final bool isSubmitting;
  final HoldingState? prior;

  const HoldingState({
    this.active = false,
    this.send = false,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        send,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  HoldingState get withoutPrior => HoldingState(
        active: active,
        send: send,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
