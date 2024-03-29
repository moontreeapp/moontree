import 'package:collection/collection.dart';
import 'package:client_back/client_back.dart';
import 'package:proclaim/proclaim.dart';

part 'status.keys.dart';

class StatusProclaim extends Proclaim<_IdKey, Status> {
  late IndexMultiple<_StatusTypeKey, Status> byStatusType;

  StatusProclaim() : super(_IdKey()) {
    byStatusType = addIndexMultiple('status-type', _StatusTypeKey());
  }
}
