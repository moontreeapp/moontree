//import 'package:backdrop/backdrop.dart';
import 'dart:async';

import 'package:client_front/application/cubits.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart';

class PageLead extends StatefulWidget {
  const PageLead({Key? key}) : super(key: key);

  @override
  _PageLead createState() => _PageLead();
}

class _PageLead extends State<PageLead> {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  String? settingTitle;
  late LeadIcon xlead = LeadIcon.pass;
  late bool loading = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.loading.listen((bool value) {
      if (value != loading) {
        setState(() {
          loading = value;
        });
      }
    }));
    listeners.add(streams.app.setting.listen((String? value) {
      if (value != settingTitle) {
        setState(() {
          settingTitle = value;
        });
      }
    }));
    listeners.add(streams.app.lead.listen((LeadIcon value) {
      if (value != xlead) {
        setState(() {
          xlead = value;
        });
      }
    }));
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
    return body();
  }

  Widget body() {
    if (loading && streams.app.page.value != 'Network') {
      return Container();
    }
    if (streams.app.page.value == 'Home' &&
        (settingTitle?.startsWith('/settings/') ?? false)) {
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            streams.app.setting.add('/settings');
            //Navigator.pop(components.routes.routeContext ?? context);
            //Navigator.pop(components.routes.routeContext ?? context);
            //Navigator.pushReplacementNamed(
            //    components.routes.routeContext ?? context, '/home',
            //    arguments: {});
            //streams.app.setting.add(settingTitle);
          });
    }
    if (streams.app.page.value != 'Home' &&
        (settingTitle?.startsWith('/settings/') ?? false)) {
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            Navigator.pop(components.routes.routeContext ?? context);
            streams.app.setting.add(settingTitle);
          });
    }

    if (streams.app.page.value == 'Home') {
      return IconButton(
          splashRadius: 24,
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            ScaffoldMessenger.of(context).clearSnackBars();
            streams.app.fling.add(true);
          },
          padding: const EdgeInsets.only(left: 16),
          icon: SvgPicture.asset('assets/icons/menu/menu.svg'));
    }
    if (streams.app.page.value == '') {
      //return Container();
    }
    if (xlead == LeadIcon.none ||
        <String>['Splash', 'Login'].contains(streams.app.page.value)) {
      return Container();
    }
    if (xlead == LeadIcon.dismiss ||
        <String>['Send', 'Scan', 'Receive'].contains(streams.app.page.value)) {
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            streams.app.lead.add(LeadIcon.pass);
            streams.app.fling.add(false);
            if (xlead == LeadIcon.dismiss) {
              streams.app.lead.add(LeadIcon.pass);
            }
            Navigator.pop(components.routes.routeContext ?? context);
          });
    }
    if (<String>[
      'Transactions',
      'Asset',
      'Main',
      'Sub',
      'Restricted',
      'Qualifier',
      'Qualifiersub',
      'Nft',
      'Channel',
    ].contains(streams.app.page.value)) {
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            streams.app.fling.add(false);
            Navigator.pop(components.routes.routeContext ?? context);
          });
    }
    if (<String>['Createlogin'].contains(streams.app.page.value)) {
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            Navigator.pushReplacementNamed(
              components.routes.routeContext ?? context,
              '/security/create/setup',
            );
            streams.app.splash.add(false);
          });
    }
    if (<String>['Backupconfirm', 'Backup'].contains(streams.app.page.value)) {
      /// the reason for this is after we took out encryptedEntropy from
      /// LeaderWallets we needed to make all the functions dealing with getting
      /// sensitive information futures, and since they're futures, we had to
      /// change the way we get that data to display it for backup purposes.
      /// so we no longer can get it on the verification page initstate because
      /// that can't support futures, so we have to get it on show and pass it
      /// to the verify page. but when you hit back on verify page it doesn't
      /// change the value that's passed to it, even though you hit the button
      /// again, instead it keeps the state of the verify page intact. therefore
      /// we will simply move them back to the home page and they'll have to
      /// start the whole process again if they try to cheat.
      return IconButton(
          splashRadius: 24,
          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value ?? false) {
              return;
            }
            Navigator.popUntil(
                components.routes.routeContext ?? context,
                //ModalRoute.withName('/home') ||
                ModalRoute.withName(components.routes
                        .nameIsInStack('/security/backup/backupintro')
                    ? '/security/backup/backupintro'
                    : '/home'));
            streams.app.lead
                .add(LeadIcon.pass); // replace with a refresh trigger?
          });
    }

    return IconButton(
        splashRadius: 24,
        icon: const Icon(Icons.chevron_left_rounded, color: Colors.white),
        onPressed: () {
          if (streams.app.scrim.value ?? false) {
            return;
          }
          Navigator.pop(components.routes.routeContext ?? context);
        });
  }
}
