import 'dart:io';

class ScreenFlags {
  bool showDialog = false;
  bool showModalBottomSheet = false;

  bool get active => showDialog || showModalBottomSheet;
}

class Keyboard {
  double maxHeight = 0;
  double height = 0;
  Keyboard();
}

class Screen {
  final double width;
  final double widthOneThird;
  final Appbar appbar;
  final Navbar navbar;
  final Pane pane;
  final Canvas canvas;
  final double hspace;
  final double wspace;
  final double bspace;
  final double toast;
  final double iconSmall;
  final double iconMedium;
  final double iconLarge;
  final double iconHuge;
  final double buttonHeight;
  final double buttonBorderRadius;
  late double height;
  late double displayHeight;
  Screen({
    required this.width,
    required this.widthOneThird,
    required this.appbar,
    required this.navbar,
    required this.pane,
    required this.canvas,
    required this.buttonHeight,
    required this.hspace,
    required this.wspace,
    required this.bspace,
    required this.toast,
    required this.iconSmall,
    required this.iconMedium,
    required this.iconLarge,
    required this.iconHuge,
    required this.buttonBorderRadius,
    required double screenHeight,
  }) {
    height = screenHeight - (Platform.isWindows ? 0 : appbar.statusBarHeight);
    //displayHeight = height - (navbar.height + appbar.height);
    displayHeight = height - appbar.height;
  }

  factory Screen.init(double height, double width, double statusBarHeight) {
    final appbar = Appbar.init(height, statusBarHeight);
    final navbar = Navbar.init(height);
    final pane = Pane.init(height, appbar, navbar);
    final canvas = Canvas.init(height, appbar, pane);
    return Screen(
      appbar: appbar,
      navbar: navbar,
      pane: pane,
      canvas: canvas,
      width: width,
      widthOneThird: (width ~/ 3).toDouble(),
      hspace: height * (16 / 760),
      wspace: height * (16 / 760),
      bspace: height * (72 / 760),
      toast: height * (496 / 760),
      iconSmall: height * (16 / 760),
      iconMedium: height * (24 / 760),
      iconLarge: height * (40 / 760),
      iconHuge: height * (48 / 760),
      buttonHeight: height * (40 / 760),
      buttonBorderRadius: height * (20 / 760),
      screenHeight: height,
    );
  }
}

class Appbar {
  final double statusBarHeightPercentage;
  final double statusBarHeight;
  final double height;

  Appbar._({
    required this.statusBarHeightPercentage,
    required this.statusBarHeight,
    required this.height,
  });

  factory Appbar.init(double height, double statusBarHeight) => Appbar._(
        height: height * (56 / 760),
        statusBarHeight: statusBarHeight,
        statusBarHeightPercentage: statusBarHeight / height,
      );

  double get top => statusBarHeight + height;
  double get topPercentage => statusBarHeightPercentage + 0;
}

class Navbar {
  final double hiddenHeight = 0;
  final double height;
  final double iconHeight;
  final double largeIconHeight;

  Navbar._({
    required this.height,
    required this.iconHeight,
    required this.largeIconHeight,
  });

  factory Navbar.init(double height) => Navbar._(
        height: height * (56 / 760),
        iconHeight: height * (24 / 760),
        largeIconHeight: height * (32 / 760),
      );
}

class Pane {
  static const double _midHeightPercent = 0.618;
  final double maxHeight;
  final double midHeight;
  final double minHeight;
  final double maxHeightPercent;
  final double midHeightPercent;
  final double minHeightPercent;

  Pane._({
    required this.maxHeight,
    required this.midHeight,
    required this.minHeight,
    required this.maxHeightPercent,
    required this.midHeightPercent,
    required this.minHeightPercent,
  });

  factory Pane.init(double height, Appbar appbar, Navbar navbar) => Pane._(
      maxHeight: height - appbar.height,
      midHeight: height * _midHeightPercent,
      minHeight: navbar.height + 20,
      maxHeightPercent: (height - appbar.height) / height,
      midHeightPercent: _midHeightPercent,
      minHeightPercent: (navbar.height + 20) / height);
}

class Canvas {
  final double midHeight;
  final double maxHeight;
  final double wSpace;

  Canvas._({
    required this.midHeight,
    required this.maxHeight,
    required this.wSpace,
  });

  factory Canvas.init(double height, Appbar appbar, Pane pane) => Canvas._(
        midHeight: height - (pane.midHeight + appbar.height),
        maxHeight: height - (pane.minHeight + appbar.height),
        wSpace: height * (32 / 360),
      );
}
