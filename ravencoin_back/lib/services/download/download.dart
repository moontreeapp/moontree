import 'package:ravencoin_back/services/download/asset.dart';
import 'history.dart';
import 'unspents.dart';
import 'queue.dart';

class DownloadService {
  AssetService asset = AssetService();
  HistoryService history = HistoryService();
  UnspentService unspents = UnspentService();
  QueueService queue = QueueService();
}
