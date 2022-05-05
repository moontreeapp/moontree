import 'package:rxdart/rxdart.dart';

import 'package:raven_electrum/raven_electrum.dart';

class ClientStreams {
  final client = BehaviorSubject<RavenElectrumClient?>();
  final connected =
      BehaviorSubject<ConnectionStatus>.seeded(ConnectionStatus.disconnected);
  final busy = BehaviorSubject<bool>.seeded(false);
  final activity = BehaviorSubject<ActivityMessage>.seeded(ActivityMessage());
}

enum ConnectionStatus { connected, connecting, disconnected }

class ActivityMessage {
  final bool active;
  final String? title;
  final String? message;

  ActivityMessage({this.active = false, this.title, this.message});
}
