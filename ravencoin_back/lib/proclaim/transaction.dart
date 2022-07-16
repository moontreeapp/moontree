import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'transaction.keys.dart';

class TransactionProclaim extends Proclaim<_TxHashKey, Transaction> {
  late IndexMultiple<_HeightKey, Transaction> byHeight;
  late IndexMultiple<_ConfirmedKey, Transaction> byConfirmed;
  static const maxInt = 1 << 63;

  TransactionProclaim() : super(_TxHashKey()) {
    byHeight = addIndexMultiple('height', _HeightKey());
    byConfirmed = addIndexMultiple('confirmed', _ConfirmedKey());
  }

  List<Transaction> get chronological => pros.transactions.data.toList()
    ..sort((a, b) => (b.height ?? maxInt).compareTo(a.height ?? maxInt));

  List<Transaction> get mempool => pros.transactions.byConfirmed.getAll(false);
}
