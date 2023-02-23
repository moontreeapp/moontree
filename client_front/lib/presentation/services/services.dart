import 'package:client_front/presentation/services/screen.dart';
import 'package:client_front/presentation/services/sail.dart';
import 'package:client_front/presentation/services/back.dart';

late Sail sail;
late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;

void init({required double height, required double width}) {
  screen = Screen.init(height, width);
  sail = Sail();
  screenflags = ScreenFlags();
  back = SystemBackButton()..initListener();
}
