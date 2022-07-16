import 'package:ravencoin_back/services/download/asset.dart';
import 'history.dart';
import 'unspents.dart';

class DownloadService {
  AssetService asset = AssetService();
  HistoryService history = HistoryService();
  UnspentService unspents = UnspentService();
}
