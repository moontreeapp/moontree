import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class FrontCreateScreen extends StatelessWidget {
  const FrontCreateScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginCreate');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16),
            height: 56,
            child: const Text(
              style: TextStyle(color: Colors.black),
              'some example setting thing',
            ),
          ),
        ],
      ),
    );
  }
}

class CreateChoice extends StatefulWidget {
  const CreateChoice({Key? key}) : super(key: key);

  @override
  _CreateChoiceState createState() => _CreateChoiceState();
}

class _CreateChoiceState extends State<CreateChoice> {
  Map<String, dynamic> data = <String, dynamic>{};
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
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return BackdropLayers(
        back: const BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(height: 76.figmaH),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 128.figmaH,
                child: moontree,
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                  alignment: Alignment.bottomCenter,
                  height: (16 + 24).figmaH,
                  child: welcomeMessage),
            ),
            SliverFillRemaining(
                hasScrollBody: false,
                child: KeyboardHidesWidgetWithDelay(
                    fade: true,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          invite,
                          const SizedBox(height: 16),
                          Row(children: <Widget>[nativeButton]),
                          const SizedBox(height: 16),
                          Row(children: <Widget>[passwordButton]),
                          const SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => SizedBox(
        height: .1534.ofMediaHeight(context),
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
      );

  Widget get welcomeMessage => Text(
        'Moontree',
        style: Theme.of(context)
            .textTheme
            .headline1
            ?.copyWith(color: AppColors.black60),
      );

  Widget get invite => Container(
      alignment: Alignment.center,
      width: .70.ofMediaWidth(context),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(components.routes.routeContext!).textTheme.bodyText2,
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
      ));

  Widget get nativeButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: '${Platform.isIOS ? 'iOS' : 'ANDROID'} PHONE SECURITY',
        onPressed: () async {
          await services.authentication
              .setMethod(method: AuthMethod.nativeSecurity);
          streams.app.splash.add(false);
          Navigator.pushReplacementNamed(context, getMethodPathCreate(),
              arguments: <String, bool>{'needsConsent': true});
        },
      );

  Widget get passwordButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: 'MOONTREE PASSWORD',
        onPressed: () async {
          await services.authentication
              .setMethod(method: AuthMethod.moontreePassword);
          streams.app.splash.add(false);
          Navigator.pushReplacementNamed(context, getMethodPathCreate(),
              arguments: <String, bool>{'needsConsent': true});
        },
      );
}
