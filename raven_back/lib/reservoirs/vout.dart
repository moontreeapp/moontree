import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'vout.keys.dart';

class VoutReservoir extends Reservoir<_VoutKey, Vout> {
  late IndexMultiple<_TransactionKey, Vout> byTransaction;
  late IndexMultiple<_SecurityKey, Vout> bySecurity;
  late IndexMultiple<_AddressKey, Vout> byAddress;

  VoutReservoir() : super(_VoutKey()) {
    byTransaction = addIndexMultiple('transaction', _TransactionKey());
    bySecurity = addIndexMultiple('security', _SecurityKey());
    byAddress = addIndexMultiple('address', _AddressKey());
  }

  /// makeshiftIndicies ///////////////////////////////////////////////////////

  /// unspent is any vout that doesn't have a corresponding vin
  /// (accroding to vin.voutPosition == vout.position && vin.vouTxId = vout.transactionId).
  static Iterable<Vout> whereUnspent(
          {Iterable<Vout>? given,
          Security? security,
          bool includeMempool = true}) =>
      (given ?? vouts.data).where((vout) =>
          ((includeMempool ? true : (vout.transaction?.confirmed ?? false)) &&
              (security != null ? vout.security == security : true) &&
              (security != null && security != securities.RVN
                  ? vout.securityValue(security: security) > 0
                  : true) &&
              vins
                  .where((vin) => ((includeMempool
                          ? true
                          : (vin.transaction?.confirmed ?? false)) &&
                      vin.voutTransactionId == vout.transactionId &&
                      vin.voutPosition == vout.position))
                  .toList()
                  .isEmpty));

  static Iterable<Vout> whereUnconfirmed(
          {Iterable<Vout>? given, Security? security}) =>
      (given ?? vouts.data).where((vout) =>
          !(vout.transaction?.confirmed ?? false) &&
          (security != null ? vout.security == security : true));
}
