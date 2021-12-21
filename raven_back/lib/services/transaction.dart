import 'package:intl/intl.dart';
import 'package:raven_back/raven_back.dart';

import 'transaction_maker.dart';

class TransactionService {
  final TransactionMaker make = TransactionMaker();

  List<Vout> accountUnspents(Account account, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: account.vouts, security: security ?? securities.RVN)
          .toList();

  List<Vout> walletUnspents(Wallet wallet, {Security? security}) =>
      VoutReservoir.whereUnspent(
              given: wallet.vouts, security: security ?? securities.RVN)
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
  List<TransactionRecord> getTransactionRecords({
    Account? account,
    Wallet? wallet,
  }) {
    var givenAddresses = account != null
        ? account.addresses.map((address) => address.address).toList()
        : wallet!.addresses.map((address) => address.address).toList();
    var transactionRecords = <TransactionRecord>[];
    for (var tx in transactions.chronological) {
      for (var vout in tx.vouts) {
        if (givenAddresses.contains(vout.toAddress)) {
          transactionRecords.add(TransactionRecord(
            out: false,
            fromAddress: '', // tx.vins[0].vout!.address, // will this work?
            toAddress: vout.toAddress,
            value: vout.securityValue(
                security: securities.primaryIndex.getOne(vout.securityId)),
            security: securities.primaryIndex
                .getOne(vout.assetSecurityId ?? securities.RVN.securityId)!,
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
          transactionRecords.add(TransactionRecord(
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

  TransactionRecord({
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
