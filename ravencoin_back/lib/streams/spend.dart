import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';
import 'package:ravencoin_back/utilities/utilities.dart';

// used in pages.send and BalanceHeader of ravencoin_front
class Spend {
  //final symbol = BehaviorSubject<String>.seeded('Ravencoin');
  //final amount = BehaviorSubject<double>.seeded(0.0);
  //final fee = BehaviorSubject<String>.seeded('Standard');
  //final note = BehaviorSubject<String>.seeded('');
  //final address = BehaviorSubject<String>.seeded('');
  //final addressName = BehaviorSubject<String>.seeded('');

  final form = BehaviorSubject<SpendForm?>.seeded(null);
  final make = BehaviorSubject<SendRequest?>.seeded(null);
  final made = BehaviorSubject<TransactionNote?>.seeded(null);
  final estimate = BehaviorSubject<SendEstimate?>.seeded(null);
  final send = BehaviorSubject<TransactionNote?>.seeded(null);
  final success = BehaviorSubject<bool?>.seeded(null);
}

class TransactionNote with ToStringMixin {
  String txHex;
  String? note;
  String? successMsg;

  TransactionNote({required this.txHex, this.note, this.successMsg});

  @override
  List<Object> get props => [txHex, note ?? 'null', successMsg ?? 'null'];

  @override
  List<String> get propNames => ['txHex', 'note?', 'successMsg?'];
}

class SpendForm with EquatableMixin {
  final String? symbol;
  final double? amount;
  final String? fee;
  final String? note;
  final String? address;
  final String? addressName;
  SpendForm({
    this.symbol,
    this.amount,
    this.fee,
    this.note,
    this.address,
    this.addressName,
  });

  @override
  String toString() => 'SpendForm(symbol=$symbol, amount=$amount, fee=$fee, '
      'note=$note, address=$address, addressName=$addressName)';

  @override
  List<Object> get props => [
        symbol ?? '',
        amount ?? '',
        fee ?? '',
        note ?? '',
        address ?? '',
        addressName ?? '',
      ];

  factory SpendForm.merge({
    SpendForm? form,
    String? symbol,
    double? amount,
    String? fee,
    String? note,
    String? address,
    String? addressName,
  }) {
    return SpendForm(
      symbol: symbol ?? form?.symbol,
      amount: amount ?? form?.amount,
      fee: fee ?? form?.fee,
      note: note ?? form?.note,
      address: address ?? form?.address,
      addressName: addressName ?? form?.addressName,
    );
  }

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object form) {
    return form is SpendForm
        ? (form.symbol == symbol &&
            form.amount == amount &&
            form.fee == fee &&
            form.note == note &&
            form.address == address &&
            form.addressName == addressName)
        : false;
  }
}
