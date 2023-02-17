import 'package:flutter/material.dart' show BuildContext;
import 'package:client_front/presentation/services/screen.dart';
import 'package:client_front/presentation/services/sailor.dart';
import 'package:client_front/presentation/services/back.dart';
import 'package:client_front/presentation/services/beamer.dart';

final BeamerService beamer = BeamerService();
late Sailor sailor;
late Screen screen;
late ScreenFlags screenflags;
late SystemBackButton back;

void init({required double height, required BuildContext mainContext}) {
  screen = Screen.init(height);
  sailor = Sailor(mainContext: mainContext);
  screenflags = ScreenFlags();
  back = SystemBackButton()..initListener();
}
