import 'package:raven/raven.dart';

Future mockPassword() async {
  await services.password.create.save('asdf');
  // simulate login? no.
  //cipherRegistry.updatePassword(altPassword: 'asdf');
}
