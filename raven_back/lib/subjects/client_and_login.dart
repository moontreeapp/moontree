import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'app_state.dart';
import 'behavior_subjects.dart';

// structure of items in stream
class ClientAndLogin extends AppState {
  final RavenElectrumClient? client;
  final bool? login;

  ClientAndLogin(this.client, this.login);

  @override
  String toString() => (client == null
      ? 'client: null, '
      : 'client: client, ' +
          (login == null
              ? 'login: null'
              : (login! ? 'login: true' : 'login: false')));
}

// stream
Stream<ClientAndLogin> get clientAndLoginStream => Rx.combineLatest2(
    ravenClientSubject.stream,
    loginSubject.stream,
    (RavenElectrumClient? client, bool? login) =>
        ClientAndLogin(client, login));

// memory of last item in stream
BehaviorSubject<ClientAndLogin> clientAndLoginSubject =
    BehaviorSubject<ClientAndLogin>()..addStream(clientAndLoginStream);
