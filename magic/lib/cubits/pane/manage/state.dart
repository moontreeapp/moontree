part of 'cubit.dart';

class ManageState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final String asset;
  final String chain;
  final String address;
  final double amount;
  final bool isSubmitting;
  final ManageState? prior;

  const ManageState({
    this.active = false,
    this.asset = '',
    this.chain = '',
    this.address = '',
    this.amount = 0,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        asset,
        chain,
        address,
        amount,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  ManageState get withoutPrior => ManageState(
        active: active,
        asset: asset,
        chain: chain,
        address: address,
        amount: amount,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
