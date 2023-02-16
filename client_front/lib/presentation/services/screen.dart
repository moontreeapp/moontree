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
      components.cubits.loadingViewv2.state.status == LoadingStatus.busy ||
      components.cubits.bottomModalSheet.state.display;
}

class Screen {
  final App app;
  final Navbar navbar;
  final FrontPageContainer frontPageContainer;
  final BackPageContainer backPageContainer;

  const Screen({
    required this.app,
    required this.navbar,
    required this.frontPageContainer,
    required this.backPageContainer,
  });

  factory Screen.init(double height) => Screen(
        app: App.init(height),
        navbar: Navbar.init(height),
        frontPageContainer: FrontPageContainer.init(height),
        backPageContainer: BackPageContainer.init(height),
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
