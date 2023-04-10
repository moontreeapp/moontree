import 'package:flutter/material.dart';

const none = <BoxShadow>[];
const frontLayer = <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 5),
  BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 1),
  BoxShadow(color: Color(0x24000000), offset: Offset(0, 2), blurRadius: 2),
];
const floatingButtons = <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, 1), blurRadius: 5),
  BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 1),
  BoxShadow(color: Color(0x24000000), offset: Offset(0, 2), blurRadius: 2),
];
const sendForm = <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, -2), blurRadius: 3),
  BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(0, 2), blurRadius: 1),
  BoxShadow(color: Color(0x1FFFFFFF), offset: Offset(0, 3), blurRadius: 2),
  BoxShadow(color: Color(0x3DFFFFFF), offset: Offset(0, 4), blurRadius: 4),
];
const navbar = const <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, 5), blurRadius: 5),
  BoxShadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: 14),
  BoxShadow(color: Color(0x3D000000), offset: Offset(0, 8), blurRadius: 10)
];
const snackbar = const <BoxShadow>[
  BoxShadow(color: Color(0x33000000), offset: Offset(0, 0), blurRadius: 5),
  BoxShadow(color: Color(0x1F000000), offset: Offset(0, 0), blurRadius: 14),
  BoxShadow(color: Color(0x3D000000), offset: Offset(0, 0), blurRadius: 10)
];
