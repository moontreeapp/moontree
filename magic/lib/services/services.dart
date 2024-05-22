import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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
late Keyboard keyboard;
late FlutterSecureStorage storage;
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
  keyboard = Keyboard();
  maestro = Maestro();
  storage = const FlutterSecureStorage();
  //server = ServerCall();
  rates = RateWaiter()..init(RVNtoFiat());
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
