import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'vout.keys.dart';

class VoutReservoir extends Reservoir<_VoutKey, Vout> {
  late IndexMultiple<_TransactionKey, Vout> byTransaction;
  late IndexMultiple<_SecurityKey, Vout> bySecurity;
  late IndexMultiple<_SecurityTypeKey, Vout> bySecurityType;
  late IndexMultiple<_AddressKey, Vout> byAddress;

  VoutReservoir() : super(_VoutKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    bySecurityType = addIndexMultiple('securityType', _SecurityTypeKey());
    byAddress = addIndexMultiple('address', _AddressKey());
  }

  /// makeshiftIndicies ///////////////////////////////////////////////////////

  /// unspent is any vout that doesn't have a corresponding vin
  /// (accroding to vin.voutPosition == vout.position && vin.voutTransactionId = vout.transactionId).
  static Iterable<Vout> whereUnspent({
    Iterable<Vout>? given,
    Security? security,
    bool includeMempool = true,
  }) =>
      //(given ?? res.vouts.data).where((Vout vout) =>
      //    (security != null ? vout.security == security : true) &&
      //    vout.vin == null);
      /*
                  */
      (given ?? res.vouts.data).where((Vout vout) =>
          ((includeMempool ? true : (vout.transaction?.confirmed ?? false)) &&
              (security != null ? vout.security == security : true) &&
              (security != null && security != res.securities.RVN
                  ? vout.securityValue(security: security) > 0
                  : true) &&
              res.vins
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
      (given ?? res.vouts.data).where((vout) =>
          !(vout.transaction?.confirmed ?? false) &&
          (security != null ? vout.security == security : true));
}
