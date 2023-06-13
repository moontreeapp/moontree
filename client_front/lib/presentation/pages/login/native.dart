import 'dart:async';
import 'package:client_front/presentation/services/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/streams/client.dart';
import 'package:client_back/services/consent.dart' show consentToAgreements;
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/login.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/domain/utils/device.dart' show getId;
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/auth.dart';
import 'package:client_front/infrastructure/services/dev.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show populateWalletsWithSensitives;
import 'package:client_front/infrastructure/services/services.dart';
import 'package:client_front/application/app/login/cubit.dart';
import 'package:client_front/presentation/widgets/login/components.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';

class LoginNative extends StatefulWidget {
  const LoginNative({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('LoginNative');

  @override
  _LoginNativeState createState() => _LoginNativeState();
}

class _LoginNativeState extends State<LoginNative> {
  Map<String, dynamic> data = <String, dynamic>{};
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  FocusNode unlockFocus = FocusNode();
  bool? autoInitiateUnlock;
  bool enabled = true;
  bool failedAttempt = false;
  bool isConsented = false;
  bool consented = false;
  late bool needsConsent;

  Future<void> finishLoadingDatabase() async {
    //if (!await finishedLoading) {
    if (await HIVE_INIT.isPartiallyLoaded()) {
      HIVE_INIT.setupDatabase2();
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
    finishLoadingDatabase();
  }

  @override
  void dispose() {
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    unlockFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      data = populateData(context, data);
    } catch (e) {
      data = <String, dynamic>{};
    }
    needsConsent = data['needsConsent'] as bool? ?? false;
    autoInitiateUnlock =
        autoInitiateUnlock ?? data['autoInitiateUnlock'] as bool? ?? true;
    if (readyToUnlock() && autoInitiateUnlock!) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await submit();
      });
      autoInitiateUnlock = false;
    }
    return BlocBuilder<LoginCubit, LoginCubitState>(builder: (context, state) {
      isConsented = state.isConsented;
      return PageStructure(
        children: <Widget>[
          if (screen.app.height >= 640) SizedBox(height: 76.figmaH),
          Container(height: 128.figmaH, child: MoontreeLogo()),
          Container(
              alignment: Alignment.bottomCenter,
              height: (16 + 24).figmaH,
              child: WelcomeMessage(text: 'Welcome Back')),
        ],
        firstLowerChildren: <Widget>[
          (needsConsent ? UlaMessage() : const SizedBox(height: 100)),
        ],
        secondLowerChildren: <Widget>[
          BottomButton(
            focusNode: unlockFocus,
            enabled: readyToUnlock(),
            label: enabled ? 'Unlock' : 'Unlocking...',
            onPressed: () async {
              await submit();
            },
          ),
        ],
      );
    });
  }

  Future<void> submit() async {
    /// just in case
    if (await HIVE_INIT.isPartiallyLoaded()) {
      await finishLoadingWaiters();

      /// doesn't await work?
      //while (!(await HIVE_INIT.isLoaded())) {
      //  await Future<void>.delayed(const Duration(milliseconds: 50));
      //}
    }

    /// there are existing wallets, we should populate them with sensitives now.
    await populateWalletsWithSensitives();
    final LocalAuthApi localAuthApi = LocalAuthApi();
    streams.app.auth.authenticating.add(true);
    final bool validate = await localAuthApi.authenticate(
        skip: devFlags.contains(DevFlag.skipPin));
    streams.app.auth.authenticating.add(false);
    if (mounted) {
      setState(() => enabled = false);
    }
    if (await services.password.lockout.handleVerificationAttempt(validate)) {
      if (!consented) {
        consented = await consentToAgreements(await getId());
      }
      login();
    } else {
      /// this is a pretty wild edge case:
      /// they were able to set nativeSecurity up but now its not working anymore
      if (localAuthApi.reason == AuthenticationResult.error) {
        streams.app.behavior.snack.add(Snack(
            message: 'Unknown login error: please set a pin on the device.',
            showOnLogin: true));
        setState(() => enabled = true);
        await Navigator.pushReplacementNamed(
          context,
          getMethodPathLogin(nativeSecurity: false),
        );
        streams.app.behavior.snack.add(Snack(
            message: 'Please set a password to secure your wallet.',
            showOnLogin: true));
      } else if (localAuthApi.reason == AuthenticationResult.failure) {
        /// while testing removal of pin after setting up native auth on ios, it
        /// seems this is the failure that occures, so the user is stuck on the
        /// login streen indefinately. works fine on android.
        /// we'll probably update the design to push them back to the create
        /// login process, allowing them to set a password... until then ios
        /// will be stuck because if we can't differentiate between .error and
        /// .failure we can't allow them to get through.
        setState(() {
          failedAttempt = true;
          enabled = true;
        });
      }
    }
  }

  bool isConnected() =>
      streams.client.connected.value == ConnectionStatus.connected;

  /// nativeSecurity has it's own timeout...
  bool readyToUnlock() =>
      //services.password.lockout.timePast() &&
      enabled && ((isConsented) || !needsConsent);
}
