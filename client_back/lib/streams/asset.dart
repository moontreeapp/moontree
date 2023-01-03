import 'package:client_back/client_back.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class AssetStreams {
  final BehaviorSubject<Asset> added = BehaviorSubject<Asset>()
    ..name = 'asset.added';
}
