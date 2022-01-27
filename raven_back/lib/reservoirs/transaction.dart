import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
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

  List<Transaction> get chronological => res.transactions.data.toList()
    ..sort((a, b) => (b.height ?? maxInt).compareTo(a.height ?? maxInt));

  List<Transaction> get mempool => res.transactions.byConfirmed.getAll(false);
}
