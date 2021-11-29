import 'package:raven_back/raven_back.dart';

Future mockPassword() async {
  await services.password.create.save('asdf');
  // simulate login? no.
  //cipherRegistry.updatePassword(altPassword: 'asdf');
}
