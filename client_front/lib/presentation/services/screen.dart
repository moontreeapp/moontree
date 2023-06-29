import 'dart:io';
import 'package:client_front/application/cubits.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class ScreenFlags {
  bool showDialog = false;
  bool showModalBottomSheet = false;

  bool get active =>
      showDialog ||
      showModalBottomSheet ||
      components.cubits.loadingView.state.status == LoadingStatus.busy ||
      components.cubits.bottomModalSheet.state.display;
}

class Screen {
  final double width;
  final App app;
  final Navbar navbar;
  final FrontPageContainer frontContainer;
  final BackPageContainer backContainer;
  final double buttonHeight;
  const Screen({
    required this.width,
    required this.app,
    required this.navbar,
    required this.frontContainer,
    required this.backContainer,
    required this.buttonHeight,
  });

  factory Screen.init(double height, double width, double statusBarHeight) {
    final app = App.init(height, statusBarHeight);
    return Screen(
      width: width,
      app: app,
      navbar: Navbar.init(height, statusBarHeight),
      frontContainer: FrontPageContainer.init(height, app),
      backContainer: BackPageContainer.init(height, app),
      buttonHeight: height * (40 / 760),
    );
  }
}

class App {
  static const double _appBarHeightPercentage = 0.07368421053;

  /// Android system bar - variable on android so we must get instead of declare
  /// and front and back stuff is determined by this
  //static const double _systemStatusBarHeightPercentage = 0.03157894737;
  final double statusBarHeightPercentage;
  final double screenHeight;
  final double systemStatusBarHeight;
  final double appBarHeight;
  late double height;

  App({
    required this.screenHeight,
    required this.statusBarHeightPercentage,
    required this.systemStatusBarHeight,
    required this.appBarHeight,
  }) {
    height = screenHeight - (Platform.isWindows ? 0 : systemStatusBarHeight);
  }

  factory App.init(double height, double statusBarHeight) => App(
        screenHeight: height,
        statusBarHeightPercentage: statusBarHeight / height,
        systemStatusBarHeight: statusBarHeight,
        appBarHeight: height * _appBarHeightPercentage,
      );

  double get top => systemStatusBarHeight + appBarHeight;
  double get topPercentage =>
      statusBarHeightPercentage + _appBarHeightPercentage;
}

class Navbar {
  static const double _maxHeightPercentage = 0.1552631579;
  static const double _midHeightPercentage = 0.087;
  //static const double _midHeightPercentage = 0.0915;
  //static const double _midHeightPercentage = 0.09473684211;
  final double maxHeight;
  final double midHeight;

  Navbar({
    required this.maxHeight,
    required this.midHeight,
  });

  factory Navbar.init(double height, double statusBarHeight) => Navbar(
        maxHeight: height * _maxHeightPercentage,
        midHeight: height * _midHeightPercentage,
      );
}

class FrontPageContainer {
  //static const double _maxHeightPercentage = 0.8947368421; //variable
  static const double _midHeightPercentage = 0.6315789474;
  static const double _minHeightPercentage = 0.07368421053;
  final double maxHeightPercentage;
  final double midHeightPercentage;
  final double maxHeight;
  final double midHeight;
  final double minHeight;
  final double hiddenHeight = 0.0;

  FrontPageContainer({
    required this.maxHeightPercentage,
    required this.midHeightPercentage,
    required this.maxHeight,
    required this.midHeight,
    required this.minHeight,
  });

  factory FrontPageContainer.init(double height, App app) => FrontPageContainer(
        maxHeightPercentage: 1 - app.topPercentage,
        midHeightPercentage: _midHeightPercentage / (1 - app.topPercentage),
        maxHeight: height * (1 - app.topPercentage),
        midHeight: height * _midHeightPercentage,
        minHeight: height * _minHeightPercentage,
      );

  double toPercentage(double small, double big) => small / big;
  double get inverseMid => maxHeight - midHeight;
  double get inverseMin => maxHeight - minHeight;
  double get inverseMidMin => midHeight - minHeight;
}

class BackPageContainer {
  //static const double _maxHeightPercentage = 0.8947368421; // (minused default status)
  static const double _midHeightPercentage = 0.2631578947;
  final double maxHeightPercentage;
  final double maxHeight;
  final double midHeight;
  final double hiddenHeight = 0.0;

  BackPageContainer({
    required this.maxHeightPercentage,
    required this.maxHeight,
    required this.midHeight,
  });

  factory BackPageContainer.init(double height, App app) => BackPageContainer(
        maxHeightPercentage: 1 - app.topPercentage,
        maxHeight: height * (1 - app.topPercentage),
        midHeight: height * _midHeightPercentage,
      );
}
