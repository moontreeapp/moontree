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
          (includeMempool || (vout.transaction?.confirmed ?? false)) &&
          (security == null || vout.security == security) &&
          (security == null ||
              security == pros.securities.currentCoin ||
              vout.securityValue(security: security) > 0) &&
          pros.vins
              .where((Vin vin) =>
                  (includeMempool || (vin.transaction?.confirmed ?? false)) &&
                  vin.voutTransactionId == vout.transactionId &&
                  vin.voutPosition == vout.position)
              .toList()
              .isEmpty);

  /// this should be easier by looking at unspents
  //(given ?? pros.vouts.records).where((Vout vout) =>
  //    pros.unspents.byVoutId.getOne(vout.transactionId, vout.position) != null);

  static Iterable<Vout> whereUnconfirmed({
    Iterable<Vout>? given,
    Security? security,
  }) =>
      (given ?? pros.vouts.records).where((Vout vout) =>
          !(vout.transaction?.confirmed ?? false) &&
          (security != null ? vout.security == security : true));

  // I think instead of clearning we could avoid download in the first place...
  Future<void> clearUnnecessaryVouts() async {
    Set<Vout> x = pros.vouts.records.toSet();
    x.removeAll(pros.wallets
        .map((Wallet w) => w.vouts)
        .expand((Iterable<Vout> i) => i)
        .toSet());
    x.removeAll(pros.wallets
        .map((Wallet w) => w.transactions)
        .expand((Set<Transaction> i) => i)
        .map((Transaction t) => t.vouts)
        .expand((List<Vout> e) => e)
        .toSet());
    x.removeAll(pros.wallets
        .map((Wallet w) => w.vins)
        .expand((Iterable<Vin> i) => i)
        .map((Vin v) => v.vout)
        .toSet());
    await pros.vouts.removeAll(x);
  }
}
