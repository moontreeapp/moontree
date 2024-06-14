part of 'cubit.dart';

class SendState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final String asset; // TODO: use domain object
  final String address; // TODO: use domain object
  final String amount; // TODO: use domain object
  final SendRequest? sendRequest; // TODO: use domain object
  //final UnsignedTransaction unsignedTransaction; // TODO: use domain object
  final String? unsignedTransaction; // TODO: use domain object
  final bool isSubmitting;
  final SendState? prior;

  const SendState({
    this.active = false,
    this.asset = '',
    this.amount = '',
    this.address = '',
    this.sendRequest,
    this.unsignedTransaction,
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        asset,
        address,
        amount,
        sendRequest,
        unsignedTransaction,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  SendState get withoutPrior => SendState(
        active: active,
        asset: asset,
        address: address,
        amount: amount,
        sendRequest: sendRequest,
        unsignedTransaction: unsignedTransaction,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
