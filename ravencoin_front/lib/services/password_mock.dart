import 'package:ravencoin_back/ravencoin_back.dart';

Future mockPassword() async {
  await services.password.create.save('asdf');
  // simulate login? no.
  //cipherRegistry.updatePassword(altPassword: 'asdf');
}
