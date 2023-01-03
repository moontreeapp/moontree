import 'package:collection/collection.dart';
import 'package:client_back/client_back.dart';
import 'package:proclaim/proclaim.dart';

part 'transaction.keys.dart';

class TransactionProclaim extends Proclaim<_IdKey, Transaction> {
  late IndexMultiple<_HeightKey, Transaction> byHeight;
  late IndexMultiple<_ConfirmedKey, Transaction> byConfirmed;
  static const int maxInt = 1 << 63;

  TransactionProclaim() : super(_IdKey()) {
    byHeight = addIndexMultiple('height', _HeightKey());
    byConfirmed = addIndexMultiple('confirmed', _ConfirmedKey());
  }

  List<Transaction> get chronological => pros.transactions.records.toList()
    ..sort((Transaction a, Transaction b) =>
        (b.height ?? maxInt).compareTo(a.height ?? maxInt));

  List<Transaction> get mempool => pros.transactions.byConfirmed.getAll(false);

  List<Transaction> get confirmed => pros.transactions.byConfirmed.getAll(true);
}
