import 'package:rxdart/rxdart.dart';

class ClientStreams {
  //final client = BehaviorSubject<RavenElectrumClient?>.seeded(null);
  final connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);
  final busy = BehaviorSubject<bool>.seeded(false);
  final activity = BehaviorSubject<ActivityMessage>.seeded(ActivityMessage());
  final download = BehaviorSubject<ActivityMessage>.seeded(ActivityMessage());
  final queue = PublishSubject<bool>();
}

enum ConnectionStatus { connected, connecting, disconnected }

class ActivityMessage {
  final bool active;
  final String? title;
  final String? message;

  ActivityMessage({this.active = false, this.title, this.message});
}
