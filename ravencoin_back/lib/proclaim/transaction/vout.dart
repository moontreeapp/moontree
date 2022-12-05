import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'vout.keys.dart';

class VoutProclaim extends Proclaim<_IdKey, Vout> {
  late IndexMultiple<_TransactionKey, Vout> byTransaction;
  late IndexMultiple<_SecurityKey, Vout> bySecurity;
  late IndexMultiple<_AddressKey, Vout> byAddress;

  VoutProclaim() : super(_IdKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    byAddress = addIndexMultiple('address', _AddressKey());
  }

  /// makeshiftIndices ///////////////////////////////////////////////////////

  /// unspent is any vout that doesn't have a corresponding vin
  /// (accroding to vin.voutPosition == vout.position && vin.voutTransactionId = vout.transactionId).
  static Iterable<Vout> whereUnspent({
    Iterable<Vout>? given,
    Security? security,
    bool includeMempool = true,
  }) =>
      //(given ?? pros.vouts.records).where((Vout vout) =>
      //    (security != null ? vout.security == security : true) &&
      //    vout.vin == null);
      /*
                  */
      (given ?? pros.vouts.records).where((Vout vout) =>
          ((includeMempool ? true : (vout.transaction?.confirmed ?? false)) &&
              (security != null ? vout.security == security : true) &&
              (security != null && security != pros.securities.currentCoin
                  ? vout.securityValue(security: security) > 0
                  : true) &&
              pros.vins
                  .where((vin) => ((includeMempool
                          ? true
                          : (vin.transaction?.confirmed ?? false)) &&
                      vin.voutTransactionId == vout.transactionId &&
                      vin.voutPosition == vout.position))
                  .toList()
                  .isEmpty));

  static Iterable<Vout> whereUnconfirmed({
    Iterable<Vout>? given,
    Security? security,
  }) =>
      (given ?? pros.vouts.records).where((vout) =>
          !(vout.transaction?.confirmed ?? false) &&
          (security != null ? vout.security == security : true));

  // I think instead of clearning we could avoid download in the first place...
  Future<void> clearUnnecessaryVouts() async {
    var x = pros.vouts.records.toSet();
    x.removeAll(pros.wallets.map((w) => w.vouts).expand((i) => i).toSet());
    x.removeAll(pros.wallets
        .map((w) => w.transactions)
        .expand((i) => i)
        .map((t) => t.vouts)
        .expand((e) => e)
        .toSet());
    x.removeAll(pros.wallets
        .map((w) => w.vins)
        .expand((i) => i)
        .map((v) => v.vout)
        .toSet());
    await pros.vouts.removeAll(x);
  }
}
