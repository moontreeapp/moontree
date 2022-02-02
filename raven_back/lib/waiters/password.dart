import 'waiter.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';

class PasswordWaiter extends Waiter {
  void init() {
    streams.password.update.listen((String? password) async {
      if (password != null) {
        await Future.delayed(const Duration(milliseconds: 250));
        await services.password.create.save(password);
        var cipher = services.cipher.updatePassword(altPassword: password);
        await services.cipher.updateWallets(cipher: cipher);
        services.cipher.cleanupCiphers();
        streams.app.snack.add(Snack(
            message: 'Password Updated',
            details: password == ''
                ? ('Password Removed!\n\n'
                    'Be careful out there!')
                : ('Please back up your password!\n\n'
                    'There is NO recovery process for lost passwords!')));
        streams.password.updated.add(true);
        streams.password.update.add(null);
      }
    });
  }
}
