/// https://github.com/moontreeapp/raven_mobile/issues/5
List<String> praseTxForMemo(tx) {
  var memos = <String>[];
  for (var item in tx['vout']) {
    var x = (item['scriptPubKey']['asm'] as String).split('OP_RETURN ');
    if (x.length == 2) {
      memos.add(x[1]);
    }
  }
  return memos;
}
