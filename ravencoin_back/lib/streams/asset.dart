import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:rxdart/rxdart.dart';

class AssetStreams {
  final added = assetAdded$;
}

final assetAdded$ = BehaviorSubject<Asset>();
