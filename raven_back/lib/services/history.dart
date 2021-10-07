import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';
import 'package:raven/utils/parse.dart';
import 'package:raven_electrum_client/methods/transaction/transaction.dart';

class HistoryService {
  History? getHistoryFrom({History? history, String? hash}) {
    history ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'history or hash required to identify record.'))();
    return history ?? histories.primaryIndex.getOne(hash ?? '');
  }

  // setter for note value on History record in reservoir
  Future<bool> saveNote(String note, {History? history, String? hash}) async {
    history = getHistoryFrom(history: history, hash: hash);
    if (history != null) {
      await histories.save(History(
          scripthash: history.scripthash,
          height: history.height,
          hash: history.hash,
          position: history.position,
          value: history.value,
          security: history.security,
          note: history.note));
      return true;
    }
    return false;
  }

  Future<String> getMemo(String txHash) async {
    return parseTxForMemo(
        await (await services.client.clientOrNull)!.getTransaction(txHash));
  }

  Future<String> saveMemo(String memo, {History? history, String? hash}) async {
    history = getHistoryFrom(history: history, hash: hash);
    if (history != null) {
      await histories.save(History(
          scripthash: history.scripthash,
          height: history.height,
          hash: history.hash,
          position: history.position,
          value: history.value,
          security: history.security,
          note: history.note,
          memo: memo));
    }
    return memo;
  }

  Future<String> getSaveMemo({History? history, String? hash}) async {
    history = getHistoryFrom(history: history, hash: hash);
    if (history != null) {
      return await saveMemo(await getMemo(history.hash), hash: history.hash);
    }
    return '';
  }
}
