import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/presentation/widgets/login/components.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart'
    show sail, screen;
import 'package:client_front/presentation/utils/animation.dart' as animation;

class LoginCreate extends StatefulWidget {
  const LoginCreate({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginCreate');

  @override
  _LoginCreateState createState() => _LoginCreateState();
}

class _LoginCreateState extends State<LoginCreate> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];

  Future<void> finishLoadingDatabase() async {
    //if (!await finishedLoading) {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupDatabase2();
    }
    //}
  }

  Future<void> finishLoadingWaiters() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupWaiters2();
    }
  }

  Future<bool> get finishedLoading async => HIVE_INIT.isLoaded();

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.active.active.listen((bool value) {
      if (value) {
        setState(() {});
      }
    }));
    () async {
      await finishLoadingDatabase();
      await services.authentication.setMethod(method: null);
    }();
//    loading();
  }

//  Future<void> loading() async {
//    components.cubits.loadingView
//        .show(title: 'something', msg: 'creating wallet');
//    await Future.delayed(Duration(seconds: 15));
//    components.cubits.loadingView.hide();
//    await Future.delayed(Duration(seconds: 1));
//    components.cubits.loadingView.show(msg: 'msg');
//    await Future.delayed(Duration(seconds: 15));
//    components.cubits.loadingView.hide();
//  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeIn(
        duration: animation.slowFadeDuration,
        child: PageStructure(
          children: <Widget>[
            if (screen.app.height >= 640) SizedBox(height: 76.figmaH),
            SizedBox(
                height: screen.app.height >= 640 ? 128.figmaH : 120,
                child: MoontreeLogo()),
            Container(
                alignment: Alignment.bottomCenter,
                height: (16 + 24).figmaH,
                child: WelcomeMessage()),
          ],
          firstLowerChildren: <Widget>[
            Container(
                alignment: Alignment.center,
                width: .70.ofMediaWidth(context),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: Theme.of(components.routes.routeContext!)
                        .textTheme
                        .bodyText2,
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Protect your wallet with:',
                          //text: "Please set the wallet protection type",
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(color: AppColors.black)),
                    ],
                  ),
                )),
          ],
          secondLowerChildren: <Widget>[
            BottomButton(
              enabled: true,
              label: '${Platform.isIOS ? 'iOS' : 'ANDROID'} PHONE SECURITY',
              onPressed: () async {
                await services.authentication
                    .setMethod(method: AuthMethod.nativeSecurity);
                sail.to('/login/create/native');
              },
            )
          ],
          thirdLowerChildren: <Widget>[
            BottomButton(
              enabled: true,
              label: 'MOONTREE PASSWORD',
              onPressed: () async {
                await services.authentication
                    .setMethod(method: AuthMethod.moontreePassword);
                sail.to(
                  '/login/create/password',
                  //replaceOverride: false,
                );
              },
            )
          ],
        ),
      );
}
