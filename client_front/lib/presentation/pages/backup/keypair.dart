import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
//import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class ShowKeypair extends StatefulWidget {
  final dynamic data;
  const ShowKeypair({this.data}) : super();

  @override
  _ShowKeypairState createState() => _ShowKeypairState();
}

class _ShowKeypairState extends State<ShowKeypair>
    with SingleTickerProviderStateMixin {
  bool validated = true;
  bool warn = true;
  late double buttonWidth;
  late String secret;
  TextEditingController password = TextEditingController();
  FocusNode existingFocus = FocusNode();
  FocusNode showFocus = FocusNode();
  bool failedAttempt = false;
  bool enabled = true;
  //ScreenshotCallback screenshotCallback = ScreenshotCallback();

  /// from exploring animations - want to return to
  //late AnimationController controller;
  //late Animation<double> animation;
  //late Animation<double> curve;
  //Offset offset = Offset(0.0, -1.0);
  @override
  void initState() {
    super.initState();
    streams.app.verify.add(false);
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.addListener(() {
      //  // maybe we can repaint the screen real quick before the screenshot is taken
      //  // or display a message telling them to write it down...
      //  print('detect screenshot');
      //});
    }

    /// from exploring animations - want to return to
    //controller = AnimationController(
    //    vsync: this, duration: const Duration(milliseconds: 2400));
    //animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    //curve = CurvedAnimation(parent: animation, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.dispose();
    }

    /// from exploring animations - want to return to
    //controller.dispose();
    password.dispose();
    existingFocus.dispose();
    showFocus.dispose();
    super.dispose();
  }

  bool get smallScreen => MediaQuery.of(context).size.height < 640;

  Future<String> get getSecret async {
    final Wallet wallet = Current.wallet;
    if (wallet is SingleWallet) {
      return (await wallet.kpWallet).privKey ?? '';
    }
    return Current.wallet.secret(Current.wallet.cipher!);
  }

  @override
  Widget build(BuildContext context) {
    buttonWidth = (MediaQuery.of(context).size.width - (17 + 17 + 16 + 16)) / 3;
    //print(1 - (48 + 48 + 16 + 8 + 8 + 72 + 56).ofAppHeight);
    return FutureBuilder<String>(
        future: getSecret,
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasData) {
            secret = snapshot.data!;
            return services.password.askCondition
                ? VerifyAuthentication(
                    parentState: this,
                    buttonLabel: 'Show Private Key',
                    intro: intro,
                    safe: safe,
                  )
                : body();
          } else {
            return const CircularProgressIndicator();
          }
        });
  }

  Widget body() => BackdropLayers(
      back: const BlankBack(),
      front: FrontCurve(
          child: Stack(children: <Widget>[
        components.page.form(
          context,
          columnWidgets: <Widget>[
            instructions,
            warning,
            words,
          ],
        ),
      ])));

  /// from exploring animations - want to return to
  /// animate()
  //Widget animate(child) => SlideTransition(
  //    position: Tween<Offset>(
  //      begin: offset,
  //      end: Offset.zero,
  //    ).animate(curve),
  //    child: FadeTransition(opacity: animation, child: child));

  Widget get intro => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'Your wallet is valuable.\nPlease create a backup!',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get safe => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'You are about to backup your private key.\nKeep it secret, keep it safe.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get instructions => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'This is the private key (wif) for this wallet. Whoever has this can access the funds.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.black),
      ));

  Widget get warning => Container(
      //height: 48,
      alignment: Alignment.topCenter,
      child: Text(
        'Be sure to back up your private key securely.',
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .subtitle1!
            .copyWith(color: AppColors.error),
      ));

  Widget get words => Container(
      height: 272 * (smallScreen ? .8 : 1),
      alignment: Alignment.center,
      padding: smallScreen ? null : const EdgeInsets.only(left: 16, right: 16),
      child: SelectableText(secret, textAlign: TextAlign.center));
}
