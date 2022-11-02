import 'package:ravencoin_back/services/download/asset.dart';
import 'history.dart';
import 'unspents.dart';
import 'queue.dart';

class DownloadService {
  /// Bridge issue - when upgrading we often erase all the data during first
  /// login, but we don't want to show getting started because they most likely
  /// do actually have value and we don't want to scare them, so we show the
  /// shimmer instead.
  bool overrideGettingStarted = false;

  AssetService asset = AssetService();
  HistoryService history = HistoryService();
  UnspentService unspents = UnspentService();
  QueueService queue = QueueService();
}
