export 'logo.dart';

import 'package:raven_front/listeners/logo.dart';

// globals
final LogoListener logoListener = LogoListener();
final AssetListener assetListener = AssetListener();

void initListeners() {
  logoListener.init();
  assetListener.init();
}
