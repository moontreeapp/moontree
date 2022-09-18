import 'package:flutter/material.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/auth.dart';
import 'package:ravencoin_front/services/storage.dart' show SecureStorage;
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/theme/colors.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/utils/extensions.dart';
import 'package:ravencoin_front/services/services.dart';

class LoginBiometric extends StatefulWidget {
  @override
  _LoginBiometricState createState() => _LoginBiometricState();
}

class _LoginBiometricState extends State<LoginBiometric> {
  Map<String, dynamic> data = {};
  late List listeners = [];
  FocusNode unlockFocus = FocusNode();

  Future<void> finishLoadingDatabase() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      HIVE_INIT.setupDatabase2();
    }
  }

  Future<void> finishLoadingWaiters() async {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await HIVE_INIT.setupWaiters2();
    }
  }

  Future<bool> get finishedLoading async => await HIVE_INIT.isLoaded();

  @override
  void initState() {
    print('loading');
    super.initState();
    listeners.add(streams.app.active.listen((bool value) {
      if (value) {
        setState(() {});
      }
    }));
    finishLoadingDatabase();
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    unlockFocus.dispose();
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
                          SizedBox(height: 100),
                          Row(children: [bioButton]),
                          SizedBox(height: 40),
                        ]))),
          ])));

  Widget get moontree => Container(
        child: SvgPicture.asset('assets/logo/moontree_logo.svg'),
        height: .1534.ofMediaHeight(context),
      );

  Widget get welcomeMessage => Text(
        'Welcome Back',
        style: Theme.of(context)
            .textTheme
            .headline1
            ?.copyWith(color: AppColors.black60),
      );

  Widget get bioButton => components.buttons.actionButton(
        context,
        enabled: true,
        label: 'Unlock',
        onPressed: () async {
          final localAuthApi = LocalAuthApi();
          final x = await localAuthApi.authenticate();
          if (x) {
            Navigator.pushReplacementNamed(context, '/home', arguments: {});
            // create ciphers for wallets we have
            services.cipher.initCiphers(
              altPassword: await SecureStorage.biometricKey,
              altSalt: await SecureStorage.biometricKey,
            );
            await services.cipher.updateWallets();
            services.cipher.cleanupCiphers();
            services.cipher.loginTime();
            streams.app.splash.add(false); // trigger to refresh app bar again
            streams.app.logout.add(false);
            streams.app.verify.add(true);
          }
        },
      );
}
