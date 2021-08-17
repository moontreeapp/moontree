/// Allows for importing two different ways, I prefer the later, See colors.dart
import 'package:flutter/material.dart';

Icon backIcon() => Icon(Icons.arrow_back, color: Colors.grey[100]);

class RavenIcons {
  RavenIcons();

  Icon get back => backIcon();
}
