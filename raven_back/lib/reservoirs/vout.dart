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
  /// (accroding to vin.voutPosition == vout.position && vin.vouTxId = vout.txId).
  static Iterable<Vout> whereUnspent(
          {Iterable<Vout>? given, Security? security}) =>
      (given ?? vouts).where((vout) => (vout.confirmed &&
          vout.security == security &&
          vout.securityValue(security: security) > 0 &&
          vins
              .where((vin) => (vin.voutTxId == vout.txId &&
                  vin.voutPosition == vout.position))
              .toList()
              .isEmpty));

  static Iterable<Vout> whereUnconfirmed(
          {Iterable<Vout>? given, Security? security}) =>
      (given ?? vouts).where((vout) =>
          !vout.confirmed && // in mempool
          vout.security == security);
}
