import 'raven_client.dart';
import 'logged_in.dart';
import 'multiple.dart';

class subjects {
  static final client = ravenClientSubject;
  static final login = loginSubject;
  static final clientAndLogin = clientAndLoginSubject;
}
