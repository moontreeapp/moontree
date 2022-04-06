import 'package:raven_back/services/download/asset.dart';
import 'history.dart';
import 'unspents.dart';

class DownloadService {
  AssetService asset = AssetService();
  HistoryService history = HistoryService();
  UnspentService unspents = UnspentService();
}
