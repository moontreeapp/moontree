import 'package:collection/collection.dart';
import 'package:raven_back/raven_back.dart';
import 'package:reservoir/reservoir.dart';

part 'status.keys.dart';

class StatusReservoir extends Reservoir<_StatusKey, Status> {
  late IndexMultiple<_StatusTypeKey, Status> byStatusType;
  late IndexMultiple<_AddressKey, Status> byAddress;
  late IndexMultiple<_AssetKey, Status> byAsset;
  late IndexMultiple<_BlockHeightKey, Status> byBlockHeight;

  StatusReservoir() : super(_StatusKey()) {
    byStatusType = addIndexMultiple('status-type', _StatusTypeKey());
    byAddress = addIndexMultiple('address', _AddressKey());
    byAsset = addIndexMultiple('asset', _AssetKey());
    byBlockHeight = addIndexMultiple('height', _BlockHeightKey());
  }
}
