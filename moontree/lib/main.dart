import 'dart:io' show Platform;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moontree/cubits/cubit.dart';
import 'package:moontree/cubits/cubits.dart';
import 'package:moontree/presentation/pages.dart';
import 'package:moontree/presentation/theme/colors.dart';
import 'package:moontree/presentation/theme/custom.dart';
import 'package:moontree/presentation/ui/navbar/navbar.dart';
import 'package:moontree/presentation/ui/panel/panel.dart';
import 'package:moontree/presentation/ui/toast/toast.dart';
import 'package:moontree/services/services.dart';

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

bool isImmersiveSticky = true;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (isImmersiveSticky) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }
  SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  if (!Platform.isIOS) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: AppColors.androidSystemBar,
        systemNavigationBarColor: AppColors.androidNavigationBar,
        systemNavigationBarIconBrightness: Brightness.light));
  }
  //ApiService.init();
  //await ApiConnection.init();

  runApp(const MoontreeApp());
}

class MoontreeApp extends StatelessWidget {
  const MoontreeApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Moontree Wallet',
        debugShowCheckedModeBanner: false,
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
                      providers: [
                        /// pages
                        BlocProvider<AppLayerCubit>(
                            create: (context) => cubits.appLayer),
                        BlocProvider<WalletLayerCubit>(
                            create: (context) => cubits.walletLayer),
                        //BlocProvider<SendLayerCubit>(
                        //    create: (context) => cubits.sendLayer),
                        //BlocProvider<RecieveLayerCubit>(
                        //    create: (context) => cubits.recieveLayer),
                        //BlocProvider<ManageLayerCubit>(
                        //    create: (BuildContext context) => cubits.manageLayer),
                        //BlocProvider<SwapLayerCubit>(
                        //    create: (BuildContext context) => cubits.swapLayer),

                        /// secondary pages
                        BlocProvider<WalletFeedCubit>(
                            create: (BuildContext context) =>
                                cubits.walletFeed),

                        /// layers
                        BlocProvider<ToastCubit>(
                            create: (context) => cubits.toast),
                        BlocProvider<TutorialCubit>(
                            create: (BuildContext context) => cubits.tutorial),
                        BlocProvider<NavbarCubit>(
                            create: (context) => cubits.navbar),
                        BlocProvider<PanelCubit>(
                            create: (context) => cubits.panel),
                      ],
                      child: const MaestroLayer(),
                    ))),
          ],
        ));
  }
}

class MaestroLayer extends StatelessWidget {
  const MaestroLayer({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        _initializeServices(
            context, constraints.maxHeight, constraints.maxWidth);
        const scaffold = Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          body: Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              PagesLayer(),
              NavbarLayer(),
              PanelLayer(),
              ToastLayer(),
              //const TutorialLayer(),
            ],
          ),
        );
        return Platform.isIOS ? scaffold : const SafeArea(child: scaffold);
      },
    );
  }

  void _initializeServices(BuildContext context, double height, double width) {
    //infraServices.version.rotate(
    //  infraServices.version.byPlatform(Platform.isIOS ? 'ios' : 'android'),
    //);
    init(
      height: height,
      width: width,
      statusBarHeight: Platform.isAndroid && isImmersiveSticky
          ? 0
          : MediaQuery.of(context).padding.top,
    );
    cubits.navbar.update(navOnly: true);
  }
}

//class MyHomePage extends StatefulWidget {
//  const MyHomePage({super.key, required this.title});
//
//  // This widget is the home page of your application. It is stateful, meaning
//  // that it has a State object (defined below) that contains fields that affect
//  // how it looks.
//
//  // This class is the configuration for the state. It holds the values (in this
//  // case the title) provided by the parent (in this case the App widget) and
//  // used by the build method of the State. Fields in a Widget subclass are
//  // always marked "final".
//
//  final String title;
//
//  @override
//  State<MyHomePage> createState() => _MyHomePageState();
//}
//
//class _MyHomePageState extends State<MyHomePage> {
//  int _counter = 0;
//
//  void _incrementCounter() {
//    setState(() {
//      // This call to setState tells the Flutter framework that something has
//      // changed in this State, which causes it to rerun the build method below
//      // so that the display can reflect the updated values. If we changed
//      // _counter without calling setState(), then the build method would not be
//      // called again, and so nothing would appear to happen.
//      _counter++;
//    });
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    // This method is rerun every time setState is called, for instance as done
//    // by the _incrementCounter method above.
//    //
//    // The Flutter framework has been optimized to make rerunning build methods
//    // fast, so that you can just rebuild anything that needs updating rather
//    // than having to individually change instances of widgets.
//    return Scaffold(
//      appBar: AppBar(
//        // TRY THIS: Try changing the color here to a specific color (to
//        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
//        // change color while the other colors stay the same.
//        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
//        // Here we take the value from the MyHomePage object that was created by
//        // the App.build method, and use it to set our appbar title.
//        title: Text(widget.title),
//      ),
//      body: Center(
//        // Center is a layout widget. It takes a single child and positions it
//        // in the middle of the parent.
//        child: Column(
//          // Column is also a layout widget. It takes a list of children and
//          // arranges them vertically. By default, it sizes itself to fit its
//          // children horizontally, and tries to be as tall as its parent.
//          //
//          // Column has various properties to control how it sizes itself and
//          // how it positions its children. Here we use mainAxisAlignment to
//          // center the children vertically; the main axis here is the vertical
//          // axis because Columns are vertical (the cross axis would be
//          // horizontal).
//          //
//          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
//          // action in the IDE, or press "p" in the console), to see the
//          // wireframe for each widget.
//          mainAxisAlignment: MainAxisAlignment.center,
//          children: <Widget>[
//            const Text(
//              'You have pushed the button this many times:',
//            ),
//            Text(
//              '$_counter',
//              style: Theme.of(context).textTheme.headlineMedium,
//            ),
//          ],
//        ),
//      ),
//      floatingActionButton: FloatingActionButton(
//        onPressed: _incrementCounter,
//        tooltip: 'Increment',
//        child: const Icon(Icons.add),
//      ), // This trailing comma makes auto-formatting nicer for build methods.
//    );
//  }
//}
