import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:rxdart/rxdart.dart';

class AssetStreams {
  final BehaviorSubject<Asset> added = assetAdded$;
}

final BehaviorSubject<Asset> assetAdded$ = BehaviorSubject<Asset>();
