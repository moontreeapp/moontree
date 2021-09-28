import 'package:raven/raven.dart';

Future mockPassword() async {
  await services.passwords.create.save('asdf');
  cipherRegistry.updatePassword(altPassword: 'asdf');
}
