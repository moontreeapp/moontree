/// notice that get_transaction.dart is tightly coupled to the datastructure of
/// of the electrum server. this has pros and cons, but currently we would only
/// use it to get the memo from a transaction, thus, I added this code to
/// accomplish only that.

import '../../raven_electrum.dart';

/// https://github.com/moontreeapp/raven_front/issues/5
/// we assume one transaction can only have one OP_RETURN
String parseAsmForMemo(String asm) {
  var x = asm.split(' ');
  var i = 0;
  for (var item in x) {
    if (item == 'OP_RETURN') return x[i + 1];
    i = i + 1;
  }
  return '';
}

extension GetMemoMethod on RavenElectrumClient {
  Future<String> getMemo(String txHash) async {
    var response = Map<String, dynamic>.from(await request(
      'blockchain.transaction.get',
      [txHash, true],
    ));
    if (response.keys.contains('vout')) {
      for (var asm in [
        for (var vout in response['vout']) vout['scriptPubKey']['asm']
      ]) {
        var ret = parseAsmForMemo(asm);
        if (ret != '') {
          return ret;
        }
      }
    }
    return '';
  }

  /// returns memos in the same order as txHashes passed in
  Future<List<String>> getMemos(List<String> txids) async {
    var futures = <Future<String>>[];
    peer.withBatch(() {
      for (var txid in txids) {
        futures.add(getMemo(txid));
      }
    });
    List<String> results = await Future.wait<String>(futures);
    return results;
  }
}
