import 'package:magic/services/routes.dart';
import 'package:magic/services/screen.dart';
import 'package:magic/services/back.dart';
import 'package:magic/services/keys.dart' as keys;
import 'package:magic/services/maestro.dart';

final RouteStack routes = RouteStack();
late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;
late Maestro maestro;
late Keyboard keyboard;

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
  //api.connect();
}
