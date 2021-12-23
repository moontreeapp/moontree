import 'package:intl/intl.dart';
import 'package:raven_back/extensions/list.dart';
import 'package:raven_back/raven_back.dart';

import 'transaction_maker.dart';

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> accountUnspents(Account account, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: account.vouts,
              security: security ?? securities.RVN,
              includeMempool: false)
          .toList();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: wallet.vouts,
              security: security ?? securities.RVN,
              includeMempool: false)
          .toList();

  Transaction? getTransactionFrom({Transaction? transaction, String? hash}) {
    transaction ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'transaction or hash required to identify record.'))();
    return transaction ?? transactions.primaryIndex.getOne(hash ?? '');
  }

  // setter for note value on Transaction record in reservoir
  Future<bool> saveNote(String note,
      {Transaction? transaction, String? hash}) async {
    transaction = getTransactionFrom(transaction: transaction, hash: hash);
    if (transaction != null) {
      await transactions.save(Transaction(
          height: transaction.height,
          transactionId: transaction.transactionId,
          confirmed: transaction.confirmed,
          note: transaction.note,
          time: transaction.time));
      return true;
    }
    return false;
  }

  /// returns a list of vins and vouts in chronological order
  /// Current.transactions
  /// a list of vouts and vins in chronological order. any Vout that points to
  /// an address we own is counted as an "In" we sum up the vouts per
  /// transaction per address and that's an in, technically.
  ///
  /// Now, any Vin that is associated with a Vout whose address is one that we
  /// own is counted as a "Out." Well, again, we sum up all vins per address per
  /// transaction and that's an "out".
  ///
  /// So you can only have up to one "In" per address per transaction and up to
  /// one "Out" per address per transaction.
  ///
  /// coinbase edge cases will not be shown yet, but could be accounted for with
  /// only additional logic.
  ///
  /// todo: aggregate by address...
  List<TransactionRecordOLD> getTransactionRecordsOLD({
    Account? account,
    Wallet? wallet,
  }) {
    var givenAddresses = account != null
        ? account.addresses.map((address) => address.address).toList()
        : wallet!.addresses.map((address) => address.address).toList();
    var transactionRecords = <TransactionRecordOLD>[];
    for (var tx in transactions.chronological) {
      for (var vout in tx.vouts) {
        if (givenAddresses.contains(vout.toAddress)) {
          transactionRecords.add(TransactionRecordOLD(
            out: false,
            fromAddress: '', // tx.vins[0].vout!.address, // will this work?
            toAddress: vout.toAddress,
            value: vout.securityValue(
                security: securities.primaryIndex.getOne(vout.securityId)),
            security:
                securities.primaryIndex.getOne(vout.assetSecurityId ?? '') ??
                    securities.RVN,
            height: tx.height,
            formattedDatetime: tx.formattedDatetime,
            amount: vout.assetValue ?? 0,
            voutId: vout.voutId,
            transactionId: tx.transactionId,
          ));
        }
      }
      for (var vin in tx.vins) {
        if (givenAddresses.contains(vin.vout?.toAddress)) {
          transactionRecords.add(TransactionRecordOLD(
            out: true,
            fromAddress: '',
            toAddress: vin.vout!.toAddress,
            value: vin.vout!.securityValue(
                security: securities.primaryIndex.getOne(vin.vout!.securityId)),
            security: securities.primaryIndex
                    .getOne(vin.vout?.assetSecurityId ?? '') ??
                securities.RVN,
            height: tx.height,
            formattedDatetime: tx.formattedDatetime,
            amount: vin.vout!.assetValue ?? 0,
            vinId: vin.vinId,
            transactionId: tx.transactionId,
          ));
        }
      }
    }
    var ret = <TransactionRecordOLD>[];
    var actual = <TransactionRecordOLD>[];
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

  /// for each transaction
  ///   get a list of all securities involved on vins.vouts and vouts
  ///   for each security involed
  ///     transaction record: sum vins - some vouts
  /// return transaction records
  List<TransactionRecord> getTransactionRecords({
    Account? account,
    Wallet? wallet,
  }) {
    var givenAddresses = account != null
        ? account.addresses.map((address) => address.address).toList()
        : wallet!.addresses.map((address) => address.address).toList();
    var transactionRecords = <TransactionRecord>[];
    for (var transaction in transactions.chronological) {
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
        transactionRecords.add(TransactionRecord(
          transaction: transaction,
          security: security!,
          totalIn: transaction.vins
              .where((vin) =>
                  givenAddresses.contains(vin.vout?.toAddress) &&
                  vin.vout?.security == security)
              .map((vin) => vin.vout?.securityValue(security: security))
              .toList()
              .sumInt(),
          totalOut: transaction.vouts
              .where((vout) =>
                  givenAddresses.contains(vout.toAddress) &&
                  vout.security == security)
              .map((vout) => vout.securityValue(security: security))
              .toList()
              .sumInt(),
          height: transaction.height,
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

  TransactionRecord({
    required this.transaction,
    required this.security,
    required this.formattedDatetime,
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

class TransactionRecordOLD {
  bool out;
  String fromAddress;
  String toAddress;
  int value;
  int? height;
  String formattedDatetime;
  int amount;
  Security security;
  String transactionId;
  String? voutId;
  String? vinId;

  TransactionRecordOLD({
    required this.out,
    required this.fromAddress,
    required this.toAddress,
    required this.value,
    required this.security,
    required this.formattedDatetime,
    required this.transactionId,
    this.height,
    this.amount = 0,
    this.vinId,
    this.voutId,
  });

  String get valueRVN {
    return NumberFormat('RVN #,##0.00000000', 'en_US').format(value);
  }

  String get valueAsset {
    return NumberFormat(
            '${security.symbol} #,##0.${'0' * (security.asset?.divisibility ?? 0)}',
            'en_US')
        .format(amount);
  }

  @override
  String toString() => 'out: $out '
      'fromAddress: $fromAddress '
      'toAddress: $toAddress '
      'value: $value '
      'height: $height '
      'formattedDatetime: $formattedDatetime '
      'amount: $amount '
      'security: $security '
      'transactionId: $transactionId '
      'voutId: $voutId '
      'vinId: $vinId ';
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
