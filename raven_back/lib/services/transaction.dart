import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';

class TransactionService {
  List<Vout> walletUnspents(Wallet wallet) =>
      VoutReservoir.whereUnspent(given: wallet.vouts, security: securities.RVN)
          .toList();

  List<Vout> accountUnspents(Account account) =>
      VoutReservoir.whereUnspent(given: account.vouts, security: securities.RVN)
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
          txId: transaction.txId,
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
            value: vout.value,
            security: securities.primaryIndex.getOne(vout.securityId) ??
                securities.RVN,
            height: tx.height,
            datetime: tx.formattedDatetime,
            amount: vout.amount ?? 0,
            voutId: vout.voutId,
            txId: tx.txId,
          ));
        }
      }
      for (Vin vin in tx.vins) {
        if (givenAddresses.contains(vin.vout!.toAddress)) {
          transactionRecords.add(TransactionRecord(
            out: false,
            fromAddress: '', // what am I supposed to do here?
            toAddress: vin.vout!.toAddress,
            value: vin.vout!.value,
            security:
                securities.primaryIndex.getOne(vin.vout?.securityId ?? '') ??
                    securities.RVN,
            height: tx.height,
            datetime: tx.formattedDatetime,
            amount: vin.vout!.amount ?? 0,
            vinId: vin.vinId,
            txId: tx.txId,
          ));
        }
      }
    }
    return transactionRecords;
  }
}

class TransactionRecord {
  bool out;
  String fromAddress;
  String toAddress;
  int value;
  int height;
  String datetime;
  int amount;
  Security security;
  String txId;
  String? voutId;
  String? vinId;

  TransactionRecord({
    required this.out,
    required this.fromAddress,
    required this.toAddress,
    required this.value,
    required this.security,
    required this.height,
    required this.datetime,
    required this.txId,
    this.amount = 0,
    this.vinId,
    this.voutId,
  });
}
