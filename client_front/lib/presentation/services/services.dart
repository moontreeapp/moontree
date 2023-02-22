import 'package:client_front/presentation/services/screen.dart';
import 'package:client_front/presentation/services/sailor.dart';
import 'package:client_front/presentation/services/back.dart';

late Sailor sailor;
late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;

void init({required double height, required double width}) {
  screen = Screen.init(height, width);
  sailor = Sailor();
  screenflags = ScreenFlags();
  back = SystemBackButton()..initListener();
}
