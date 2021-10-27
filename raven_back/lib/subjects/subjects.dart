import 'behavior_subjects.dart';
import 'client_and_login.dart';
// import 'ciphers_accounts.dart';

class subjects {
  static final client = ravenClientSubject;
  static final login = loginSubject;
  static final cipherUpdate = cipherUpdateSubject;
  static final clientAndLogin = clientAndLoginSubject;
  // static final ciphersAccounts = ciphersAccountsStream;
}
