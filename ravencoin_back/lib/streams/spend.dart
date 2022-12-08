import 'package:equatable/equatable.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ravencoin_back/records/vout.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';

// used in pages.send and BalanceHeader of ravencoin_front
class Spend {
  //final symbol = BehaviorSubject<String>.seeded('Ravencoin');
  //final amount = BehaviorSubject<double>.seeded(0.0);
  //final fee = BehaviorSubject<String>.seeded('Standard');
  //final note = BehaviorSubject<String>.seeded('');
  //final address = BehaviorSubject<String>.seeded('');
  //final addressName = BehaviorSubject<String>.seeded('');

  final BehaviorSubject<SendRequest?> make =
      BehaviorSubject<SendRequest?>.seeded(null);
  final BehaviorSubject<TransactionNote?> made =
      BehaviorSubject<TransactionNote?>.seeded(null);
  final BehaviorSubject<SendEstimate?> estimate =
      BehaviorSubject<SendEstimate?>.seeded(null);
  final BehaviorSubject<TransactionNote?> send =
      BehaviorSubject<TransactionNote?>.seeded(null);
  final BehaviorSubject<bool?> success = BehaviorSubject<bool?>.seeded(null);
}

class TransactionNote with ToStringMixin {
  TransactionNote({
    required this.txHex,
    this.note,
    this.successMsg,
    this.usedUtxos,
  });
  String txHex;
  String? note;
  String? successMsg;
  Set<Vout>? usedUtxos;

  @override
  List<Object> get props => <Object>[
        txHex,
        note ?? 'null',
        successMsg ?? 'null',
        usedUtxos ?? 'null'
      ];

  @override
  List<String> get propNames =>
      <String>['txHex', 'note?', 'successMsg?', 'usedUtxos?'];
}

class SpendForm with EquatableMixin {
  SpendForm({
    this.symbol,
    this.amount,
    this.fee,
    this.note,
    this.address,
    this.addressName,
  });

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
  final String? symbol;
  final double? amount;
  final String? fee;
  final String? note;
  final String? address;
  final String? addressName;

  @override
  String toString() => 'SpendForm(symbol=$symbol, amount=$amount, fee=$fee, '
      'note=$note, address=$address, addressName=$addressName)';

  @override
  List<Object> get props => <Object>[
        symbol ?? '',
        amount ?? '',
        fee ?? '',
        note ?? '',
        address ?? '',
        addressName ?? '',
      ];

  set symbol(String? symbol) => this.symbol = symbol;

  @override
  bool operator ==(Object other) =>
      other is SpendForm &&
      (other.symbol == symbol &&
          other.amount == amount &&
          other.fee == fee &&
          other.note == note &&
          other.address == address &&
          other.addressName == addressName);
}
