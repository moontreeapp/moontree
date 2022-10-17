import 'package:collection/collection.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:proclaim/proclaim.dart';

part 'status.keys.dart';

class StatusProclaim extends Proclaim<_StatusKey, Status> {
  late IndexMultiple<_StatusTypeKey, Status> byStatusType;
  late IndexMultiple<_AddressKey, Status> byAddress;
  late IndexMultiple<_AssetKey, Status> byAsset;
  late IndexMultiple<_BlockHeightKey, Status> byBlockHeight;

  StatusProclaim() : super(_StatusKey()) {
    byStatusType = addIndexMultiple('status-type', _StatusTypeKey());
    byAddress = addIndexMultiple('address', _AddressKey());
    byAsset = addIndexMultiple('asset', _AssetKey());
    byBlockHeight = addIndexMultiple('height', _BlockHeightKey());
  }
}
