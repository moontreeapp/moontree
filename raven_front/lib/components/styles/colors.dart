import 'package:flutter/material.dart';

Color seeThrough() => Colors.transparent;
Color disabledColor() => Colors.grey;
Color goodColor() => Colors.green[800] ?? seeThrough();
Color fineColor() => Colors.grey[900] ?? seeThrough();
Color badColor() => Colors.red[900] ?? seeThrough();
Color whisperColor() => Colors.grey[600] ?? seeThrough();

class RavenColor {
  RavenColor();

  Color get disabled => disabledColor();
  Color get good => goodColor();
  Color get fine => fineColor();
  Color get bad => badColor();
  Color get whisper => whisperColor();
}
