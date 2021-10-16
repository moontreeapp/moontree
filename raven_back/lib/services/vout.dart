import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';

class TransactionService {
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
          addressId: transaction.addressId,
          height: transaction.height,
          txId: transaction.txId,
          confirmed: transaction.confirmed,
          note: transaction.note));
      return true;
    }
    return false;
  }
}
