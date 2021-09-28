import 'package:raven/raven.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';
import 'package:rxdart/rxdart.dart';

import 'app_state.dart';
import 'behavior_subjects.dart';

//accountsAndLogin = <AccountAndLogin>{};
class AccountAndLogin extends AppState {
  final Account? account;
  final bool login;

  AccountAndLogin(this.account, this.login);

  @override
  String toString() => (account == null
      ? 'account: null, '
      : 'account: client, ' + (login ? 'login: true' : 'login: false'));
}

Stream<AccountAndLogin> get accountAndLoginStream => Rx.combineLatest2(
    ravenClientSubject.stream,
    loginSubject.stream,
    (RavenElectrumClient? client, bool login) =>
        AccountAndLogin(client, login));

BehaviorSubject<AccountAndLogin> accountAndLoginSubject =
    BehaviorSubject<AccountAndLogin>()..addStream(accountAndLoginStream);
