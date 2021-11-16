export 'logo.dart';

import 'package:raven_mobile/listeners/logo.dart';

// globals
final LogoListener logoListener = LogoListener();

void initListeners() {
  logoListener.init();
}
