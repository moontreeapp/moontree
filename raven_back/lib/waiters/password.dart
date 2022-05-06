import 'waiter.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';

class PasswordWaiter extends Waiter {
  void init() {
    streams.password.update.listen((String? password) async {
      if (password != null) {
        var sendSnack = true;
        if (!services.password.required) {
          sendSnack = false;
        }
        await services.password.create.save(password);
        var cipher = services.cipher.updatePassword(altPassword: password);
        await services.cipher.updateWallets(cipher: cipher);
        services.cipher.cleanupCiphers();
        if (sendSnack) {
          streams.app.snack
              .add(Snack(message: 'Successfully Updated Password'));
        }
        streams.password.update.add(null);
      }
    });
  }
}
