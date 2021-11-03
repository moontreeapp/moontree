import 'cipher.dart';
import 'password.dart';
import 'replay.dart';
import 'subjects.dart';

class streams {
  static final cipher = CipherStreams();
  static final password = PasswordStreams();
  static final replay = ReplayStreams();
  static final app = appStatusSubject;
  static final login = loginSubject;
  static final client = ravenClientSubject;
}
