export 'package:magic/services/derivation.dart';
export 'package:magic/domain/storage/storage.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:magic/services/rate.dart';
import 'package:magic/services/routes.dart';
import 'package:magic/services/screen.dart';
import 'package:magic/services/back.dart';
import 'package:magic/services/keys.dart' as keys;
import 'package:magic/services/maestro.dart';
//import 'package:magic/services/calls/server.dart';
import 'package:magic/services/subscription.dart';
import 'package:magic/services/triggers/rate.dart';

final RouteStack routes = RouteStack();
late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;
late Maestro maestro;
//late Keyboard keyboard;
late FlutterSecureStorage secureStorage;
const Future<SharedPreferences> Function() storage =
    SharedPreferences.getInstance;
final SubscriptionService subscription = SubscriptionService();
//late ServerCall server;
bool initialized = false;
late RateWaiter rates;

void init({
  required double height,
  required double width,
  required double statusBarHeight,
}) {
  screen = Screen.init(height, width, statusBarHeight);
  screenflags = ScreenFlags();
  back = SystemBackButton()..initListener();
  keys.init();
  //keyboard = Keyboard();
  maestro = Maestro();
  secureStorage = const FlutterSecureStorage();
  //server = ServerCall();
  rates = RateWaiter(
      evrGrabber: RateGrabber(symbol: 'EVR'),
      rvnGrabber: RateGrabber(symbol: 'RVN'))
    ..init();
  initialized = true;

  //api.connect();
  /// here we could have a process that loads from local disk (wallets, settings)
  /// then a process which connects to the server and setsup subscriptions on the client:
  //      await subscription.setupSubscription(
  //        wallets: cubits.wallets.currentWallet,
  //        chain: value.chain,
  //        net: value.net,
  //      );
}
