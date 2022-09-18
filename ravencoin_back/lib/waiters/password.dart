import 'waiter.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class PasswordWaiter extends Waiter {
  void init() {
    streams.password.update.listen((Map<String, String>? passwordMap) async {
      if (passwordMap != null) {
        final password = passwordMap['password']!;
        final salt = passwordMap['salt']!;
        final message = passwordMap['message']!;
        var sendSnack = true;
        if (!services.password.required) {
          sendSnack = false;
        }
        await services.password.create.save(password, salt);
        var cipher = services.cipher.updatePassword(altPassword: password);
        await services.cipher.updateWallets(cipher: cipher);
        services.cipher.cleanupCiphers();
        if (sendSnack && /*message != null &&*/ message != '') {
          streams.app.snack.add(Snack(message: message));
        }
        streams.password.update.add(null);
      }
    });
  }
}
