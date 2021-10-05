import 'package:raven_electrum_client/methods/get_transaction.dart';

/// https://github.com/moontreeapp/raven_mobile/issues/5
/// we assume one transaction can only have one OP_RETURN
String praseTxForMemo(Transaction tx) {
  for (var item in tx.vout) {
    var x = item.scriptPubKey.asm.split(' ');
    var i = 0;
    for (var item in x) {
      if (item == 'OP_RETURN') return x[i + 1];
      i = i + 1;
    }
  }
  return '';
}
