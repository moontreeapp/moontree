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
