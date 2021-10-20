import 'package:collection/collection.dart';
import 'package:raven/raven.dart';
import 'package:reservoir/reservoir.dart';

part 'transaction.keys.dart';

class TransactionReservoir extends Reservoir<_TxHashKey, Transaction> {
  late IndexMultiple<_HeightKey, Transaction> byHeight;
  late IndexMultiple<_ConfirmedKey, Transaction> byConfirmed;
  static const maxInt = 1 << 63;

  TransactionReservoir() : super(_TxHashKey()) {
    byHeight = addIndexMultiple('height', _HeightKey());
    byConfirmed = addIndexMultiple('confirmed', _ConfirmedKey());
  }

  List<Transaction> get chronological => transactions.data.toList()
    ..sort((a, b) => (b.height ?? -1).compareTo(a.height ?? -1));
}
