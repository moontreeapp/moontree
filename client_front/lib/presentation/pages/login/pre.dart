import 'package:client_back/services/consent.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/domain/utils/auth.dart';
import 'package:client_front/domain/utils/device.dart';
import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/infrastructure/services/password.dart';
import 'package:client_front/presentation/services/services.dart' show sail;

class PreLogin extends StatelessWidget {
  const PreLogin({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('PreLogin');

  @override
  Widget build(BuildContext context) {
    routeToLogin(context);
    return SizedBox.shrink();
  }

  Future<void> routeToLogin(BuildContext context) async {
    // this is false on 1st startup -> create
    if (!services.password.required) {
      Future<void>.microtask(
          () => sail.to('/login/create', replaceOverride: true));
    } else {
      await maybeSwitchToPassword();
      if (services.password.interruptedPasswordChange()) {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: const Text('Issue detected'),
                    content: const Text(
                        'Change Password process in progress, please submit your previous password...'),
                    actions: <Widget>[
                      TextButton(
                          child: const Text('ok'),
                          onPressed: () => sail.to(
                                '/login/create/resume',
                                replaceOverride: true,
                                arguments: <String, dynamic>{},
                              ))
                    ]));
      } else {
        bool hasConsented = false;
        try {
          hasConsented = await discoverConsent(await getId());
        } catch (e) {
          streams.app.behavior.snack.add(Snack(
            message: 'Unable to connect! Please check connectivity.',
          ));
        }
        Future<void>.microtask(() => sail.to(getMethodPathLogin(),
            replaceOverride: true,
            arguments: <String, bool>{'needsConsent': !hasConsented}));
      }
    }
  }
/*
    */
}
