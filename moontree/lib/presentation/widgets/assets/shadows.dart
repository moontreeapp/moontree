import 'package:flutter/material.dart';

const none = <BoxShadow>[];
const frontLayer = <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 5),
  BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 1),
  BoxShadow(color: Color(0x24000000), offset: Offset(0, 2), blurRadius: 2),
];
