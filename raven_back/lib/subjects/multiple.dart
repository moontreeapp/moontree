import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'app_state.dart';
import 'raven_client.dart';
import 'logged_in.dart';

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

  Map<String, int> get matrix => {
        'client: null, login: null': 0,
        'client: null, login: false': 1,
        'client: null, login: true': 2,
        'client: client, login: null': 3,
        'client: client, login: false': 4,
        'client: client, login: true': 5,
      };
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
