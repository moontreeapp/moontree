import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class ClientStreams {
  final BehaviorSubject<ConnectionStatus> connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected)
        ..name = 'client.connected';
  final BehaviorSubject<bool> busy = BehaviorSubject<bool>.seeded(false)
    ..name = 'client.busy';
}

enum ConnectionStatus { connected, connecting, disconnected }
