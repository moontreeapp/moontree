import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';

import 'package:raven_front/pages/pages.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/theme.dart';

import 'package:raven_front/backdrop/backdrop.dart';

import 'widgets/widgets.dart';
import 'package:raven_front/backdrop/lib/modified_draggable_scrollable_sheet.dart'
    as slide;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message ${message.messageId}');
}

Future<void> main() async {
  // Catch errors without crashing the app:
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Firebase.initializeApp();

    // Let local development handle errors normally
    await FirebaseCrashlytics.instance
        .setCrashlyticsCollectionEnabled(!kDebugMode);
    // NOTE: To test firebase crashlytics in debug mode, set the above to
    // `true` and call `FirebaseCrashlytics.instance.crash()` at some point
    //  later in the code.

    // Errors that we don't catch should be sent to Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // In-app error notification when foregrounded
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: false,
    );

    runApp(RavenMobileApp());
  }, (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack));
}

class RavenMobileApp extends StatelessWidget {
  //static final GlobalKey<NavigatorState> navigatorKey = new GlobalKey();
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return MaterialApp(
      initialRoute: '/',
      routes: pages
          .routes(context), // look up flutter view model for sub app structure.
      themeMode: ThemeMode.system,
      theme: CustomTheme.lightTheme,
      darkTheme: CustomTheme.lightTheme,
      navigatorObservers: [components.navigator],
      builder: (context, child) {
        components.navigator.scaffoldContext = context;
        final controller = slide.DraggableScrollableController();
        return Scaffold(
          appBar: BackdropAppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            automaticallyImplyLeading: false,
            elevation: 0,
            leading: PageLead(mainContext: context),
            title: /*FittedBox(fit: BoxFit.fitWidth, child: */ PageTitle() /*)*/,
            actions: <Widget>[
              components.status,
              ConnectionLight(),
              QRCodeContainer(),
              SnackBarViewer(),
              SizedBox(width: 6),
            ],
          ),
          body: Stack(
            children: [
              BackLayer(),
              slide.DraggableScrollableActuator(
                child: slide.DraggableScrollableSheet(
                    controller: controller,
                    initialChildSize: 0.5,
                    maxChildSize: 1,
                    minChildSize: 0.5,
                    snap: true,
                    builder: (context, scrollController) {
                      components.navigator.scrollController = scrollController;
                      return Container(
                        color: Colors.white,
                        child: child!,
                      );
                    }),
              )
            ],
          ),
        );
        /*
        return BackdropScaffold(
          //scaffoldKey: components.scaffoldKey, // thought this could help scrim issue, but it didn't
          //maintainBackLayerState: false,
          //resizeToAvoidBottomInset: true,
          //extendBody: true,
          // for potentially modifying the persistent bottom sheet options:
          stickyFrontLayer: true,
          backgroundColor: Theme.of(context).backgroundColor,
          backLayerBackgroundColor: Theme.of(context).backgroundColor,
          frontLayerElevation: 1,
          frontLayerBackgroundColor: Colors.transparent,
          frontLayerBorderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8), topRight: Radius.circular(8)),
          frontLayerBoxShadow: [
            BoxShadow(
                color: const Color(0x33000000),
                offset: Offset(0, 1),
                blurRadius: 5),
            BoxShadow(
                color: const Color(0x1F000000),
                offset: Offset(0, 3),
                blurRadius: 1),
            BoxShadow(
                color: const Color(0x24000000),
                offset: Offset(0, 2),
                blurRadius: 2),
          ],
          appBar: BackdropAppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Theme.of(context).backgroundColor,
            elevation: 0,
            leading: PageLead(mainContext: context),
            title: /*FittedBox(fit: BoxFit.fitWidth, child: */ PageTitle() /*)*/,
            actions: <Widget>[
              components.status,
              ConnectionLight(),
              QRCodeContainer(),
              SnackBarViewer(),
              SizedBox(width: 6),
            ],
          ),
          backLayer: BackLayer(),
          frontLayer: Container(
            color: Colors.white,
            child: child!,
          ),
        );
        */
      },
    );
  }

  Widget header = Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      color: Colors.white,
      width: double.infinity,
      child: const Center(
        child: Text('Content',
            style: TextStyle(fontSize: 20, color: Colors.black)),
      ),
    ),
  );
}
