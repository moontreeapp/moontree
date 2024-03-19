import 'package:moontree/services/screen.dart';
import 'package:moontree/services/back.dart';
import 'package:moontree/services/keys.dart' as keys;
//import 'package:moontree/services/maestro.dart';

late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;
//late Maestro maestro;

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
  //maestro = Maestro();
  //api.connect();
}
