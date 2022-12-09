import 'package:rxdart/rxdart.dart';

class ClientStreams {
  //final client = BehaviorSubject<RavenElectrumClient?>.seeded(null);
  final BehaviorSubject<ConnectionStatus> connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);
  final BehaviorSubject<bool> busy = BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<ActivityMessage> activity =
      BehaviorSubject<ActivityMessage>.seeded(ActivityMessage());
  final BehaviorSubject<ActivityMessage> download =
      BehaviorSubject<ActivityMessage>.seeded(ActivityMessage());
  final PublishSubject<bool> queue = PublishSubject<bool>();
}

enum ConnectionStatus { connected, connecting, disconnected }

class ActivityMessage {
  ActivityMessage({this.active = false, this.title, this.message});
  final bool active;
  final String? title;
  final String? message;
}
