import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/streams/client.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_back/services/consent.dart'
    show ConsentDocument, documentEndpoint, consentToAgreements;
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/services/wallet.dart'
    show saveSecret, setupWallets;
import 'package:ravencoin_front/theme/extensions.dart';
import 'package:ravencoin_front/utils/auth.dart';
import 'package:ravencoin_front/utils/login.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/device.dart' show getId;
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/services/services.dart';
import 'package:url_launcher/url_launcher.dart';

class CreateChoice extends StatefulWidget {
  @override
  _CreateChoiceState createState() => _CreateChoiceState();
}

class _CreateChoiceState extends State<CreateChoice> {
  Map<String, dynamic> data = {};
  late List listeners = [];

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

  Future<bool> get finishedLoading async => await HIVE_INIT.isLoaded();

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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    return BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => GestureDetector(
      onTap: FocusScope.of(context).unfocus,
      child: Container(
          padding: EdgeInsets.only(left: 16, right: 16, top: 0, bottom: 0),
          child: CustomScrollView(slivers: <Widget>[
            SliverToBoxAdapter(
              child: SizedBox(height: 76.figmaH),
            ),
            SliverToBoxAdapter(
              child: Container(
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
                        children: [
                          invite,
                          SizedBox(height: 16),
                          Row(children: [nativeButton]),
                          SizedBox(height: 16),
                          Row(children: [passwordButton]),
                          SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
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
          style:
              Theme.of(components.navigator.routeContext!).textTheme.bodyText2,
          children: <TextSpan>[
            TextSpan(
                text: "Protect your wallet with:",
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
        label: 'ANDROID PHONE SECURITY',
        onPressed: () async {
          await services.authentication
              .setMethod(method: AuthMethod.nativeSecurity);
          streams.app.splash.add(false);
          Navigator.pushReplacementNamed(context, getMethodPathCreate(),
              arguments: {'needsConsent': true});
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
              arguments: {'needsConsent': true});
        },
      );
}
