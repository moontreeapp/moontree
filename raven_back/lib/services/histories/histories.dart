import 'package:raven/services/service.dart';
import 'package:raven/records.dart';
import 'package:raven/reservoirs.dart';

class HistoryService extends Service {
  late final HistoryReservoir histories;

  HistoryService(this.histories) : super();

  // setter for note value on History record in reservoir
  bool saveNote(String hash, String note, {History? history}) {
    history = history ?? histories.primaryIndex.getOne(hash);
    if (history != null) {
      histories.save(History(
          accountId: history.accountId,
          walletId: history.walletId,
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
