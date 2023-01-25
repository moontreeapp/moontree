part of 'cubit.dart';

@immutable
class SimpleSendFormState extends CubitState {
  final Security security;
  final String address;
  final double amount;
  final FeeRate fee;
  final String memo;
  final String note;
  final String addressName;
  final bool isSubmitting;

  const SimpleSendFormState({
    required this.security,
    this.address = '',
    this.amount = 0.0,
    this.fee = standardFee,
    this.memo = '',
    this.note = '',
    this.addressName = '',
    this.isSubmitting = false,
  });

  @override
  String toString() =>
      'SpendForm(security=$security, address=$address, amount=$amount, '
      'fee=$fee, note=$note, addressName=$addressName, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object> get props => <Object>[
        security,
        address,
        amount,
        fee,
        memo,
        note,
        addressName,
        isSubmitting,
      ];

  factory SimpleSendFormState.initial() =>
      SimpleSendFormState(security: pros.securities.currentCoin);

  SimpleSendFormState load({
    Security? security,
    String? address,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? addressName,
    bool? isSubmitting,
  }) =>
      SimpleSendFormState.load(
        form: this,
        security: security,
        address: address,
        amount: amount,
        fee: fee,
        memo: memo,
        note: note,
        addressName: addressName,
        isSubmitting: isSubmitting,
      );

  factory SimpleSendFormState.load({
    required SimpleSendFormState form,
    Security? security,
    String? address,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? addressName,
    bool? isSubmitting,
  }) =>
      SimpleSendFormState(
        security: security ?? form.security,
        address: address ?? form.address,
        amount: amount ?? form.amount,
        fee: fee ?? form.fee,
        memo: memo ?? form.memo,
        note: note ?? form.note,
        addressName: addressName ?? form.addressName,
        isSubmitting: isSubmitting ?? form.isSubmitting,
      );

  String get fiatRepresentation {
    try {
      return services.conversion.securityAsReadable(
        sats,
        symbol: security.symbol,
        asUSD: true,
      );
    } catch (e) {
      return '';
    }
  }

  int get sats => amount.asSats;
}
