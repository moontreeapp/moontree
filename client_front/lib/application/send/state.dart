part of 'cubit.dart';

@immutable
class SimpleSendFormState extends CubitState {
  final Security security;
  final String address;
  final String changeAddress;
  final double amount;
  final FeeRate fee;
  final String memo;
  final String note;
  final String addressName;
  final UnsignedTransactionResult? unsigned;
  final wutx.Transaction? signed;
  final String? txHash;
  final bool isSubmitting;

  const SimpleSendFormState({
    required this.security,
    this.address = '',
    this.changeAddress = '',
    this.amount = 0.0,
    this.fee = standardFee,
    this.memo = '',
    this.note = '',
    this.addressName = '',
    this.unsigned,
    this.signed,
    this.txHash,
    this.isSubmitting = false,
  });

  @override
  String toString() =>
      'SpendForm(security=$security, address=$address, amount=$amount, '
      'fee=$fee, note=$note, addressName=$addressName, unsigned=$unsigned, '
      'signed=$signed, txHash=$txHash, changeAddress=$changeAddress, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        security,
        address,
        amount,
        fee,
        memo,
        note,
        changeAddress,
        addressName,
        unsigned,
        signed,
        txHash,
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
    String? changeAddress,
    String? addressName,
    UnsignedTransactionResult? unsigned,
    wutx.Transaction? signed,
    String? txHash,
    bool? isSubmitting,
  }) =>
      SimpleSendFormState(
        security: security ?? this.security,
        address: address ?? this.address,
        amount: amount ?? this.amount,
        fee: fee ?? this.fee,
        memo: memo ?? this.memo,
        note: note ?? this.note,
        changeAddress: changeAddress ?? this.changeAddress,
        addressName: addressName ?? this.addressName,
        unsigned: unsigned ?? this.unsigned,
        signed: signed ?? this.signed,
        txHash: txHash ?? this.txHash,
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
