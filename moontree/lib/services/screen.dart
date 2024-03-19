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
  final App app;
  final Navbar navbar;
  final Home home;
  final FrontPageContainer frontContainer;
  final BackPageContainer backContainer;
  final CommentsContainer commentsContainer;
  final TagTools tagTools;
  final Zoom zoom;
  final double buttonHeight;
  final double hspace;
  final double wspace;
  final double bspace;
  final double toast;
  const Screen({
    required this.width,
    required this.widthOneThird,
    required this.app,
    required this.navbar,
    required this.home,
    required this.frontContainer,
    required this.backContainer,
    required this.commentsContainer,
    required this.tagTools,
    required this.zoom,
    required this.buttonHeight,
    required this.hspace,
    required this.wspace,
    required this.bspace,
    required this.toast,
  });

  factory Screen.init(double height, double width, double statusBarHeight) {
    final navbar = Navbar.init(height, width, statusBarHeight);
    final app = App.init(height, statusBarHeight, navbar);
    return Screen(
      width: width,
      widthOneThird: (width ~/ 3).toDouble(),
      app: app,
      navbar: navbar,
      home: Home.init(height, navbar),
      frontContainer: FrontPageContainer.init(height, app),
      backContainer: BackPageContainer.init(height, app),
      commentsContainer: CommentsContainer.init(height),
      tagTools: TagTools.init(app, navbar),
      zoom: Zoom.init(width),
      buttonHeight: height * (40 / 760),
      hspace: height * (16 / 760), //0.02173913043478260869565217391304
      wspace: height * (16 / 760),
      bspace: height * (72 / 760),
      toast: height * (496 / 760), // 200 from bottom
    );
  }
}

class App {
  static const double _appBarHeightPercentage =
      0.07368421052631578947368421052632;

  /// Android system bar - variable on android so we must get instead of declare
  /// and front and back stuff is determined by this
  //static const double _systemStatusBarHeightPercentage = 0.03157894737;
  static const double _buttonBorderRadiusPercentage = 20 / 760;
  final double statusBarHeightPercentage;
  final double screenHeight;
  final double systemStatusBarHeight;
  final double appBarHeight;
  late double height;
  late double displayHeight;
  final double buttonBorderRadius;

  App._({
    required this.screenHeight,
    required this.statusBarHeightPercentage,
    required this.systemStatusBarHeight,
    required this.appBarHeight,
    required this.buttonBorderRadius,
    navbar,
  }) {
    height = screenHeight - (Platform.isWindows ? 0 : systemStatusBarHeight);
    displayHeight = height - navbar.sectionsHeight;
  }

  factory App.init(double height, double statusBarHeight, Navbar navbar) =>
      App._(
        screenHeight: height,
        statusBarHeightPercentage: statusBarHeight / height,
        systemStatusBarHeight: statusBarHeight,
        appBarHeight: height * _appBarHeightPercentage,
        buttonBorderRadius: height * _buttonBorderRadiusPercentage,
        navbar: navbar,
      );

  double get top => systemStatusBarHeight + appBarHeight;
  double get topPercentage =>
      // app bar is in front of front, not on top of it anymore.
      statusBarHeightPercentage + 0 /*_appBarHeightPercentage*/;
}

class CommentsContainer {
  static const double _fullHeightPercentage = 1;
  final double hiddenHeight = 0.0;
  final double fullHeight;

  CommentsContainer._({
    required this.fullHeight,
  });

  factory CommentsContainer.init(double height) => CommentsContainer._(
        fullHeight: height * _fullHeightPercentage,
      );
}

class Navbar {
  static const double _maxHeightPercentage = 486 / 760;
  //static const double _midHeightPercentage = 0.1947368421052632;

  static const double _midHeightPercentage = 122 / 760;
  static const double _navHeightPercentage = 178 / 760;
  static const double _itemWidthPercentage = 1 / 3;
  static const double _iconHeightPercentage = 24 / 760;
  static const double _largeIconHeightPercentage = 32 / 760;
  static const double _carouselHeightPercentage = 74 / 760;
  static const double _carouselPaddingPercentage = 16 / 760;
  final double fullHeight;
  final double maxHeight;
  final double navHeight;
  final double midHeight;
  final double minHeight = 32;
  final double hiddenHeight = 0;
  final double sectionsHeight;
  final double itemWidth;
  final double itemHeight;
  final double iconHeight;
  final double largeIconHeight;
  final double carouselHeight;

  /// padding above and below carousel
  final double carouselPadding;

  Navbar._({
    required this.fullHeight,
    required this.maxHeight,
    required this.navHeight,
    required this.midHeight,
    required this.sectionsHeight,
    required this.itemWidth,
    required this.itemHeight,
    required this.iconHeight,
    required this.largeIconHeight,
    required this.carouselHeight,
    required this.carouselPadding,
  });
  //height: 759.2727272727273,
  //width: 392.72727272727275,
  //statusBarHeight: 24.0
  //maxHeight: 485.53492822966507,
  //midHeight: 147.85837320574166,
  //itemWidth: 130.9090909090909,
  //carouselHeight: 73.92918660287083

  factory Navbar.init(double height, double width, double statusBarHeight) =>
      Navbar._(
        fullHeight: height - statusBarHeight - 56,
        maxHeight: height * _maxHeightPercentage,
        navHeight: height * _navHeightPercentage,
        midHeight: height * _midHeightPercentage,
        sectionsHeight:
            (height * _navHeightPercentage) - (height * _midHeightPercentage),
        carouselHeight: height * _carouselHeightPercentage,
        carouselPadding: height * _carouselPaddingPercentage,
        itemWidth: width * _itemWidthPercentage,
        itemHeight: height * _carouselHeightPercentage * .9,
        iconHeight: height * _iconHeightPercentage,
        largeIconHeight: height * _largeIconHeightPercentage,
      );
}

class Home {
  static const double _videoTimeIndicatorHeightPercentage = 2 / 760;
  static const double _selectionIconHeightPercentage = 64 / 760;
  final double videoTimeIndicatorHeight;
  final double videoScreenHeight;
  final double selectionIconHeight;

  Home._({
    required this.videoTimeIndicatorHeight,
    required this.videoScreenHeight,
    required this.selectionIconHeight,
  });

  factory Home.init(double height, Navbar navbar) => Home._(
        videoTimeIndicatorHeight: height * _videoTimeIndicatorHeightPercentage,
        videoScreenHeight: height - navbar.sectionsHeight,
        selectionIconHeight: height * _selectionIconHeightPercentage,
      );
}

class FrontPageContainer {
  //static const double _maxHeightPercentage = 0.8947368421; //variable
  static const double _midHeightPercentage = 480 / 760;
  static const double _minHeightPercentage = 56 / 760;
  final double maxHeightPercentage;
  final double midHeightPercentage;
  final double maxHeight;
  final double midHeight;
  final double minHeight;
  final double hiddenHeight = 0.0;

  FrontPageContainer._({
    required this.maxHeightPercentage,
    required this.midHeightPercentage,
    required this.maxHeight,
    required this.midHeight,
    required this.minHeight,
  });

  factory FrontPageContainer.init(double height, App app) =>
      FrontPageContainer._(
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
  static const double _midHeightPercentage = 200 / 760;
  final double maxHeightPercentage;
  final double maxHeight;
  final double midHeight;
  final double hiddenHeight = 0.0;

  BackPageContainer._({
    required this.maxHeightPercentage,
    required this.maxHeight,
    required this.midHeight,
  });

  factory BackPageContainer.init(double height, App app) => BackPageContainer._(
        maxHeightPercentage: 1 - app.topPercentage,
        maxHeight: height * (1 - app.topPercentage),
        midHeight: height * _midHeightPercentage,
      );
}

class Zoom {
  static const double _widthPercentage = .618;
  final double width;
  final double offset;

  Zoom._({
    required this.width,
    required this.offset,
  });

  factory Zoom.init(double width) => Zoom._(
        width: width * _widthPercentage,
        offset: (width * (1 - _widthPercentage)) / 2,
      );
}

class TagTools {
  static const double _itemHeightPercentage = (36 / 148);
  static const double _iconHeightPercentage = (24 / 148);
  final double fullHeight;
  final double height;
  final double itemHeight;
  final double iconHeight;

  TagTools._({
    required this.fullHeight,
    required this.height,
    required this.itemHeight,
    required this.iconHeight,
  });

  factory TagTools.init(App app, Navbar navbar) => TagTools._(
        fullHeight: app.height - navbar.midHeight,
        height: navbar.minHeight * 2.5,
        itemHeight: (navbar.midHeight) * _itemHeightPercentage,
        iconHeight: (navbar.midHeight) * _iconHeightPercentage,
      );
}
