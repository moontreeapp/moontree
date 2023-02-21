import 'dart:io';
import 'dart:async';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/services/services.dart' show sailor;

class FrontCreateScreen extends StatefulWidget {
  const FrontCreateScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginCreate');

  @override
  _FrontCreateScreenState createState() => _FrontCreateScreenState();
}

class _FrontCreateScreenState extends State<FrontCreateScreen> {
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
    listeners.add(streams.app.active.listen((bool value) {
      if (value) {
        setState(() {});
      }
    }));
    () async {
      await finishLoadingDatabase();
      await services.authentication.setMethod(method: null);
    }();
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeIn(
      child: GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Container(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(children: <Widget>[
                      SizedBox(height: 76.figmaH),
                      SizedBox(
                        height: 128.figmaH,
                        child: SizedBox(
                          height: .1534.ofMediaHeight(context),
                          child:
                              SvgPicture.asset('assets/logo/moontree_logo.svg'),
                        ),
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          height: (16 + 24).figmaH,
                          child: Text(
                            'Moontree',
                            style: Theme.of(context)
                                .textTheme
                                .headline1
                                ?.copyWith(color: AppColors.black60),
                          )),
                    ]),
                    Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.center,
                              width: .70.ofMediaWidth(context),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style:
                                      Theme.of(components.routes.routeContext!)
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
                          const SizedBox(height: 16),
                          Row(children: <Widget>[
                            // todo: make buttons a widget, rather than a function that returns a widget.
                            components.buttons.actionButton(
                              context,
                              enabled: true,
                              label:
                                  '${Platform.isIOS ? 'iOS' : 'ANDROID'} PHONE SECURITY',
                              onPressed: () async {
                                await services.authentication.setMethod(
                                    method: AuthMethod.nativeSecurity);
                                streams.app.splash.add(false);
                                //Navigator.pop(context);
                                sailor.sailTo(
                                  location: '/login/create/native',
                                  //replaceOverride: false,
                                );
                                //Navigator.pushReplacementNamed(
                                //    context, getMethodPathCreate(),
                                //    arguments: <String, bool>{
                                //      'needsConsent': true
                                //    });
                              },
                            )
                          ]),
                          const SizedBox(height: 16),
                          Row(children: <Widget>[
                            components.buttons.actionButton(
                              context,
                              enabled: true,
                              label: 'MOONTREE PASSWORD',
                              onPressed: () async {
                                await services.authentication.setMethod(
                                    method: AuthMethod.moontreePassword);
                                streams.app.splash.add(false);
                                //Navigator.pop(context);
                                sailor.sailTo(
                                  location: '/login/create/password',
                                  //replaceOverride: false,
                                );
                                //Navigator.pushReplacementNamed(
                                //    context, getMethodPathCreate(),
                                //    arguments: <String, bool>{
                                //      'needsConsent': true
                                //    });
                              },
                            )
                          ]),
                          const SizedBox(height: 40),
                        ]),
                  ]))));
}
