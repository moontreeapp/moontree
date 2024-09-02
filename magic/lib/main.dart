import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:magic/presentation/widgets/assets/icons.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/custom.dart';
import 'package:magic/presentation/ui/canvas/canvas.dart';
import 'package:magic/presentation/ui/ignore/ignore.dart';
import 'package:magic/presentation/ui/ui.dart';
import 'package:magic/services/services.dart';
import 'package:magic/services/security.dart';

/// to remove stupid overscroll glow indicator
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;
}

Future<void> precacheSvgPicture(String assetName) async {
  final loader = SvgAssetLoader(assetName);
  await svg.cache
      .putIfAbsent(loader.cacheKey(null), () => loader.loadBytes(null));
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!Platform.isIOS) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  } else {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
      //overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top],
    );
  }
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (Platform.isAndroid) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColors.androidSystemBar,
        systemNavigationBarColor: AppColors.androidNavigationBar,
        systemNavigationBarIconBrightness: Brightness.light));
  }
  if (Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: AppColors.white,
    ));
  }

  // Initialize the Serverpod client with a retry mechanism to handle connection issues
  await subscription.setupClient(FlutterConnectivityMonitor(),
      retryCount: 3, retryDelay: const Duration(seconds: 2));
  await precacheSvgPicture(LogoIcons.magic);

  //ApiService.init();
  //await ApiConnection.init();
  runApp(const MagicApp());
}

class MagicApp extends StatelessWidget {
  const MagicApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Magic Wallet',
        debugShowCheckedModeBanner: false,
        color: AppColors.background,
        key: routes.appKey,
        theme: CustomTheme.lightTheme,
        darkTheme: CustomTheme.lightTheme,
        navigatorKey: routes.navigatorKey,
        navigatorObservers: <NavigatorObserver>[routes],
        home: Overlay(
          initialEntries: [
            OverlayEntry(
                builder: (context) => ScrollConfiguration(
                    behavior: NoGlowScrollBehavior(),
                    child: MultiBlocProvider(
                      providers: cubits.providers,
                      child: Platform.isIOS
                          ? const MaestroLayerIOS()
                          : const MaestroLayer(),
                    ))),
          ],
        ));
  }
}

void _initializeServices(BuildContext context, double height, double width) {
  //infraServices.version.rotate(
  //  infraServices.version.byPlatform(Platform.isIOS ? 'ios' : 'android'),
  //);
  if (initialized &&
      screen.initializedWidth == width &&
      screen.initializedHeight == height) {
    return;
  }
  init(
    height:
        height + (Platform.isIOS ? MediaQuery.of(context).padding.top / 2 : 0),
    width: width,
    statusBarHeight:
        Platform.isIOS ? MediaQuery.of(context).padding.top / 2 : 0,
  );
  // Add this function at the top level of your file

  cubits.welcome.update(active: true, child: const WelcomeBackScreen());
  cubits.menu.update(active: true);
  cubits.ignore.update(active: true);
  cubits.pane.update(
    active: true,
    initial: screen.pane.midHeightPercent,
    min: screen.pane.minHeightPercent,
    max: screen.pane.maxHeightPercent,
  );
  cubits.pane.update(height: screen.pane.midHeight);
  cubits.ignore.update(active: false);
  _clearAuthAndLoadKeys(context);
}

/// here we load keys so everything is ready for the user after they login,
/// they can't get past the welcome screen without logging in. the only way
/// to get the user experience wanted.
Future<void> _clearAuthAndLoadKeys(BuildContext context) async {
  await securityService.clearAuthentication();
  await cubits.keys.loadPrivKeys();
  subscription.ensureConnected().then((_) {
    subscription.setupSubscriptions(cubits.keys.master);
    cubits.wallet.populateAssets().then((_) => maestro.activateHome());
  });
}

class MaestroLayer extends StatelessWidget {
  const MaestroLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _initializeServices(
            context, constraints.maxHeight, constraints.maxWidth);
        final scaffold = Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.background,
          body: SizedBox(
            height: screen.height,
            width: screen.width,
            child: const Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                AppbarLayer(),
                CanvasLayer(),
                PaneLayer(),
                //NavbarLayer(),
                PanelLayer(),
                IgnoreLayer(),
                WelcomeLayer(),
                ToastLayer(),
                //const TutorialLayer(),
              ],
            ),
          ),
        );
        //return Platform.isIOS ? SafeArea(child: scaffold) : scaffold;
        return scaffold;
      },
    );
  }
}

class MaestroLayerIOS extends StatefulWidget {
  const MaestroLayerIOS({super.key});

  @override
  State<MaestroLayerIOS> createState() => _MaestroLayerIOSState();
}

class _MaestroLayerIOSState extends State<MaestroLayerIOS> {
  Widget? cachedLayout;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        if (cachedLayout == null || hasSignificantChange(constraints)) {
          cachedLayout = buildLayout(constraints);
        }
        return cachedLayout!;
      },
    );
  }

  bool hasSignificantChange(BoxConstraints constraints) {
    // Implement logic to check if the constraints have changed significantly
    // E.g., return constraints.maxHeight > 500; or similar logic.
    return false; // Placeholder for actual logic
  }

  Widget buildLayout(BoxConstraints constraints) {
    if (Platform.isIOS) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;
      final safeAreaHeight = MediaQuery.of(context).padding.top +
          MediaQuery.of(context).padding.bottom;
      final usableHeight = screenHeight;
      _initializeServices(context, usableHeight, screenWidth);
    } else {
      _initializeServices(context, constraints.maxHeight, constraints.maxWidth);
    }
    final scaffold = Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: SizedBox(
        height: screen.height,
        width: screen.width,
        child: const Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            AppbarLayer(),
            CanvasLayer(),
            PaneLayer(),
            //NavbarLayer(),
            PanelLayer(),
            IgnoreLayer(),
            WelcomeLayer(),
            ToastLayer(),
            //const TutorialLayer(),
          ],
        ),
      ),
    );
    //return Platform.isIOS ? SafeArea(child: scaffold) : scaffold;
    return scaffold;
  }
}
