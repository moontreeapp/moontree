import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'app_state.dart';
import 'behavior_subjects.dart';

class ClientAndLogin extends AppState {
  final RavenElectrumClient? client;
  final bool login;

  ClientAndLogin(this.client, this.login);

  @override
  String toString() => (client == null
      ? 'client: null, '
      : 'client: client, ' + (login ? 'login: true' : 'login: false'));
}

Stream<ClientAndLogin> get clientAndLoginStream => Rx.combineLatest2(
    ravenClientSubject.stream,
    loginSubject.stream,
    (RavenElectrumClient? client, bool login) => ClientAndLogin(client, login));

BehaviorSubject<ClientAndLogin> clientAndLoginSubject =
    BehaviorSubject<ClientAndLogin>()..addStream(clientAndLoginStream);
