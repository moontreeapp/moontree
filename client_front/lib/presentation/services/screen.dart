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

  factory Screen.init(double height, double width) => Screen(
        width: width,
        app: App.init(height),
        navbar: Navbar.init(height),
        frontContainer: FrontPageContainer.init(height),
        backContainer: BackPageContainer.init(height),
        buttonHeight: height * (40 / 760),
      );
}

class App {
  static const double _appBarHeightPercentage = 0.07368421053;
  // Android system bar
  static const double _systemStatusBarHeightPercentage = 0.03157894737;
  final double screenHeight;
  final double systemStatusBarHeight;
  final double appBarHeight;
  late double height;

  App({
    required this.screenHeight,
    required this.systemStatusBarHeight,
    required this.appBarHeight,
  }) {
    height = screenHeight - (Platform.isWindows ? 0 : systemStatusBarHeight);
  }

  factory App.init(double height) => App(
        screenHeight: height,
        systemStatusBarHeight: height * _systemStatusBarHeightPercentage,
        appBarHeight: height * _appBarHeightPercentage,
      );
}

class Navbar {
  static const double _maxHeightPercentage = 0.1552631579;
  static const double _midHeightPercentage = 0.09473684211;
  final double maxHeight;
  final double midHeight;

  Navbar({
    required this.maxHeight,
    required this.midHeight,
  });

  factory Navbar.init(double height) => Navbar(
        maxHeight: height * _maxHeightPercentage,
        midHeight: height * _midHeightPercentage,
      );
}

class FrontPageContainer {
  static const double _maxHeightPercentage = 0.8947368421;
  static const double _midHeightPercentage = 0.6315789474;
  static const double _minHeightPercentage = 0.07368421053;
  final double midHeightPercentage =
      _midHeightPercentage / _maxHeightPercentage;
  final double maxHeight;
  final double midHeight;
  final double minHeight;
  final double hiddenHeight = 0.0;

  FrontPageContainer({
    required this.maxHeight,
    required this.midHeight,
    required this.minHeight,
  });

  factory FrontPageContainer.init(double height) => FrontPageContainer(
        maxHeight: height * _maxHeightPercentage,
        midHeight: height * _midHeightPercentage,
        minHeight: height * _minHeightPercentage,
      );

  double midtoPercentage(double small, double big) => small / big;
}

class BackPageContainer {
  static const double _maxHeightPercentage = 0.8947368421;
  static const double _midHeightPercentage = 0.2631578947;
  final double maxHeight;
  final double midHeight;
  final double hiddenHeight = 0.0;

  BackPageContainer({
    required this.maxHeight,
    required this.midHeight,
  });

  factory BackPageContainer.init(double height) => BackPageContainer(
        maxHeight: height * _maxHeightPercentage,
        midHeight: height * _midHeightPercentage,
      );
}
