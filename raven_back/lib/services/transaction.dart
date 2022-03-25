import 'package:intl/intl.dart';
import 'package:raven_back/raven_back.dart';

import 'transaction_maker.dart';

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: wallet.vouts,
              security: security ?? res.securities.RVN,
              includeMempool: false)
          .toList();

  Transaction? getTransactionFrom({Transaction? transaction, String? hash}) {
    transaction ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'transaction or hash required to identify record.'))();
    return transaction ?? res.transactions.primaryIndex.getOne(hash ?? '');
  }

  /// for each transaction
  ///   get a list of all securities involved on vins.vouts and vouts
  ///   for each security involed
  ///     transaction record: sum vins - some vouts
  /// return transaction records
  List<TransactionRecord> getTransactionRecords({
    required Wallet wallet,
  }) {
    var givenAddresses =
        wallet.addresses.map((address) => address.address).toList();
    var transactionRecords = <TransactionRecord>[];
    for (var transaction in res.transactions.chronological) {
      var securitiesInvolved = ((transaction.vins
                  .where((vin) =>
                      givenAddresses.contains(vin.vout?.toAddress) &&
                      vin.vout?.security != null)
                  .map((vin) => vin.vout?.security)
                  .toList()) +
              (transaction.vouts
                  .where((vout) =>
                      givenAddresses.contains(vout.toAddress) &&
                      vout.security != null)
                  .map((vout) => vout.security)
                  .toList()))
          .toSet();
      for (var security in securitiesInvolved) {
        var selfIn = transaction.vins
            .where((vin) =>
                givenAddresses.contains(vin.vout?.toAddress) &&
                vin.vout?.security == security)
            .map((vin) => vin.vout?.securityValue(security: security))
            .toList()
            .sumInt();
        var othersIn = transaction.vins
            .where((vin) =>
                !givenAddresses.contains(vin.vout?.toAddress) &&
                vin.vout?.security == security)
            .map((vin) => vin.vout?.securityValue(security: security))
            .toList()
            .sumInt();
        var othersOut = transaction.vouts
            .where((vout) =>
                !givenAddresses.contains(vout.toAddress) &&
                vout.security == security)
            .map((vout) => vout.securityValue(security: security))
            .toList()
            .sumInt();
        var selfOut = transaction.vouts
            .where((vout) =>
                givenAddresses.contains(vout.toAddress) &&
                vout.security == security)
            .map((vout) => vout.securityValue(security: security))
            .toList()
            .sumInt();
        transactionRecords.add(TransactionRecord(
          transaction: transaction,
          security: security!,
          totalIn: selfIn,
          totalOut: selfOut,
          height: transaction.height,
          toSelf: selfIn == selfOut,
          formattedDatetime: transaction.formattedDatetime,
        ));
      }
    }
    var ret = <TransactionRecord>[];
    var actual = <TransactionRecord>[];
    for (var txRecord in transactionRecords) {
      if (txRecord.formattedDatetime == 'in mempool') {
        ret.add(txRecord);
      } else {
        actual.add(txRecord);
      }
    }
    ret.addAll(actual);
    return ret;
  }
}

class TransactionRecord {
  Transaction transaction;
  Security security;
  String formattedDatetime;
  int totalIn;
  int totalOut;
  int? height;
  bool? toSelf = false;

  TransactionRecord({
    required this.transaction,
    required this.security,
    required this.formattedDatetime,
    this.toSelf,
    this.height,
    this.totalIn = 0,
    this.totalOut = 0,
  });

  int get value => (totalIn - totalOut).abs();
  bool get out => (totalIn - totalOut) >= 0;
  String get formattedValue => security.symbol == 'RVN'
      ? NumberFormat('RVN #,##0.00000000', 'en_US').format(value)
      : NumberFormat(
              '${security.symbol} #,##0.${'0' * (security.asset?.divisibility ?? 0)}',
              'en_US')
          .format(value);

  @override
  String toString() => 'TransactionRecord('
      'transaction: $transaction, '
      'security: $security, '
      'totalIn: $totalIn, '
      'totalOut: $totalOut, '
      'formattedDatetime: $formattedDatetime, '
      'height: $height)';
}

class SecurityTotal {
  final Security security;
  final int value;

  SecurityTotal({required this.security, required this.value});

  SecurityTotal operator +(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value + other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");

  SecurityTotal operator -(SecurityTotal other) => security == other.security
      ? SecurityTotal(security: security, value: value - other.value)
      : throw BalanceMismatch("Securities don't match - can't combine");
}
