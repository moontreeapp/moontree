part of 'cubit.dart';

@immutable
class SimpleSendFormState with EquatableMixin {
  final String symbol;
  final double amount;
  final String fee;
  final String note;
  final String address;
  final String addressName;
  final bool isSubmitting;

  SimpleSendFormState({
    required this.symbol,
    this.amount = 0.0,
    this.fee = '',
    this.note = '',
    this.address = '',
    this.addressName = '',
    this.isSubmitting = false,
  });

  @override
  String toString() => 'SpendForm(symbol=$symbol, amount=$amount, fee=$fee, '
      'note=$note, address=$address, addressName=$addressName, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object> get props => [
        symbol,
        amount,
        fee,
        note,
        address,
        addressName,
      ];

  factory SimpleSendFormState.initial() => SimpleSendFormState(
        symbol: pros.securities.currentCrypto.symbol,
      );

  SimpleSendFormState load({
    String? symbol,
    double? amount,
    String? fee,
    String? note,
    String? address,
    String? addressName,
    bool? isSubmitting,
  }) =>
      SimpleSendFormState.load(
        form: this,
        symbol: symbol,
        amount: amount,
        fee: fee,
        note: note,
        address: address,
        addressName: addressName,
        isSubmitting: isSubmitting,
      );

  factory SimpleSendFormState.load({
    required SimpleSendFormState form,
    String? symbol,
    double? amount,
    String? fee,
    String? note,
    String? address,
    String? addressName,
    bool? isSubmitting,
  }) {
    return SimpleSendFormState(
      symbol: symbol ?? form.symbol,
      amount: amount ?? form.amount,
      fee: fee ?? form.fee,
      note: note ?? form.note,
      address: address ?? form.address,
      addressName: addressName ?? form.addressName,
      isSubmitting: isSubmitting ?? form.isSubmitting,
    );
  }

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object form) {
    return form is SimpleSendFormState
        ? (form.symbol == symbol &&
            form.amount == amount &&
            form.fee == fee &&
            form.note == note &&
            form.address == address &&
            form.addressName == addressName)
        : false;
  }
}
