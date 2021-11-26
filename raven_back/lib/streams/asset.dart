import 'package:raven/raven.dart';
import 'package:rxdart/rxdart.dart';

class AssetStreams {
  final added = assetAdded$;
}

final assetAdded$ = BehaviorSubject<Asset>();
