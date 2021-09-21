import 'package:raven/utils/exceptions.dart';
import 'package:raven/raven.dart';

class HistoryService {
  // setter for note value on History record in reservoir
  bool saveNote(String note, {History? history, String? hash}) {
    history ??
        hash ??
        (() => throw OneOfMultipleMissing(
            'history or hash required to identify record.'))();
    history = history ?? histories.primaryIndex.getOne(hash ?? '');
    if (history != null) {
      histories.save(History(
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
}
