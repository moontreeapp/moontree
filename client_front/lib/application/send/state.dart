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
      SimpleSendFormState(
        security: security ?? this.security,
        address: address ?? this.address,
        amount: amount ?? this.amount,
        fee: fee ?? this.fee,
        memo: memo ?? this.memo,
        note: note ?? this.note,
        addressName: addressName ?? this.addressName,
        isSubmitting: isSubmitting ?? this.isSubmitting,
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
