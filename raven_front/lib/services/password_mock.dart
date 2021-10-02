import 'package:raven/raven.dart';

Future mockPassword() async {
  await services.passwords.create.save('asdf');
  // simulate login? no.
  //cipherRegistry.updatePassword(altPassword: 'asdf');
}
