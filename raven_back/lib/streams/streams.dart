import 'app.dart';
import 'cipher.dart';
import 'client.dart';
import 'password.dart';
import 'replay.dart';
import 'wallet.dart';

class streams {
  static final app = AppStreams();
  static final cipher = CipherStreams();
  static final client = ClientStreams();
  static final password = PasswordStreams();
  static final replay = ReplayStreams();
  static final wallet = WalletStreams();
}
