import 'dart:async';
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
//import 'package:screenshot_callback/screenshot_callback.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/theme/colors.dart';

class ShowKeypair extends StatefulWidget {
  final dynamic data;
  const ShowKeypair({this.data}) : super();

  @override
  _ShowKeypairState createState() => _ShowKeypairState();
}

class _ShowKeypairState extends State<ShowKeypair>
    with SingleTickerProviderStateMixin {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  late double buttonWidth;
  late String secret;
  @override
  void initState() {
    super.initState();
    //streams.app.auth.verify.add(false);
    if (Platform.isAndroid) {
      FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.addListener(() {
      //  // maybe we can repaint the screen real quick before the screenshot is taken
      //  // or display a message telling them to write it down...
      //  print('detect screenshot');
      //});
    }
    //listeners.add(streams.app.auth.verify.listen((value) {
    //  if (value == true) {
    //    setState(() {});
    //  }
    //}));
  }

  @override
  void dispose() {
    if (Platform.isAndroid) {
      FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
    } else if (Platform.isIOS) {
      //screenshotCallback.dispose();
    }
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
            return
                //services.password.askCondition
                //? VerifyAuthentication(
                //    buttonLabel: 'Show Private Key',
                //    intro: Container(
                //        //height: 48,
                //        alignment: Alignment.topCenter,
                //        child: Text(
                //          'Your wallet is valuable.\nPlease create a backup!',
                //          textAlign: TextAlign.center,
                //          style: Theme.of(context)
                //              .textTheme
                //              .titleMedium!
                //              .copyWith(color: AppColors.black),
                //        )),
                //  )
                //:
                PageStructure(
              children: <Widget>[
                Container(
                    //height: 48,
                    alignment: Alignment.topCenter,
                    child: Text(
                      'This is the private key (wif) for this wallet. Whoever has this can access the funds.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.black),
                    )),
                Container(
                    //height: 48,
                    alignment: Alignment.topCenter,
                    child: Text(
                      'Be sure to back up your private key securely.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(color: AppColors.error),
                    )),
                Container(
                    height: 272 * (smallScreen ? .8 : 1),
                    alignment: Alignment.center,
                    padding: smallScreen
                        ? null
                        : const EdgeInsets.only(left: 16, right: 16),
                    child: SelectableText(secret, textAlign: TextAlign.center)),
              ],
              firstLowerChildren: <Widget>[],
            );
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
