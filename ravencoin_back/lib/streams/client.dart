import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class ClientStreams {
  //final client = BehaviorSubject<RavenElectrumClient?>.seeded(null);
  final BehaviorSubject<ConnectionStatus> connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected)
        ..name = 'client.connected';
  final BehaviorSubject<bool> busy = BehaviorSubject<bool>.seeded(false)
    ..name = 'client.busy';
  final BehaviorSubject<ActivityMessage> activity =
      BehaviorSubject<ActivityMessage>.seeded(ActivityMessage())
        ..name = 'client.activity';
  final BehaviorSubject<ActivityMessage> download =
      BehaviorSubject<ActivityMessage>.seeded(ActivityMessage())
        ..name = 'client.download';
  final PublishSubject<bool> queue = PublishSubject<bool>()
    ..name = 'client.queue';
}

enum ConnectionStatus { connected, connecting, disconnected }

class ActivityMessage {
  ActivityMessage({this.active = false, this.title, this.message});
  final bool active;
  final String? title;
  final String? message;
}
