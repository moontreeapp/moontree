export 'logo.dart';

import 'package:raven_mobile/listeners/logo.dart';

// globals
final LogoListener logoListener = LogoListener();
final AssetListener assetListener = AssetListener();

void initListeners() {
  logoListener.init();
  assetListener.init();
}
