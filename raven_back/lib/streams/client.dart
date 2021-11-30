import 'package:rxdart/rxdart.dart';

import 'package:raven_electrum/raven_electrum.dart';

class ClientStreams {
  final client = ravenClientSubject$;
  final connected = ravenClientConnected$;
}

final ravenClientSubject$ = BehaviorSubject<RavenElectrumClient?>();
final ravenClientConnected$ = BehaviorSubject<bool>.seeded(false);
