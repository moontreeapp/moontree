import 'package:raven_back/raven_back.dart';
import 'package:rxdart/rxdart.dart';

class AssetStreams {
  final added = assetAdded$;
}

final assetAdded$ = BehaviorSubject<Asset>();
