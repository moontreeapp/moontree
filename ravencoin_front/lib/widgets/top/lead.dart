//import 'package:backdrop/backdrop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';

class PageLead extends StatefulWidget {
  final BuildContext mainContext;

  PageLead({Key? key, required this.mainContext}) : super(key: key);

  @override
  _PageLead createState() => _PageLead();
}

class _PageLead extends State<PageLead> {
  late String pageTitle = '';
  late String? settingTitle = null;
  late LeadIcon xlead = LeadIcon.pass;
  late bool loading = false;
  late List listeners = [];

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
    listeners.add(streams.app.page.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
    listeners.add(streams.app.setting.listen((value) {
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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return body();
  }

  Widget body() {
    if (loading && pageTitle != 'Network') {
      return Container();
    }
    if (pageTitle == 'Home' &&
        (settingTitle?.startsWith('/settings/') ?? false)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            streams.app.setting.add('/settings');
            //Navigator.pop(components.navigator.routeContext ?? context);
            //Navigator.pop(components.navigator.routeContext ?? context);
            //Navigator.pushReplacementNamed(
            //    components.navigator.routeContext ?? context, '/home',
            //    arguments: {});
            //streams.app.setting.add(settingTitle);
          });
    }
    if (pageTitle != 'Home' &&
        (settingTitle?.startsWith('/settings/') ?? false)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            Navigator.pop(components.navigator.routeContext ?? context);
            streams.app.setting.add(settingTitle);
          });
    }

    if (pageTitle == 'Home') {
      return IconButton(
          splashRadius: 24,
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            ScaffoldMessenger.of(context).clearSnackBars();
            streams.app.fling.add(true);
          },
          padding: EdgeInsets.only(left: 16),
          icon: SvgPicture.asset('assets/icons/menu/menu.svg'));
    }
    if (pageTitle == '') {
      //return Container();
    }
    if (xlead == LeadIcon.none || ['Splash', 'Login'].contains(pageTitle)) {
      return Container();
    }
    if (xlead == LeadIcon.dismiss ||
        ['Send', 'Scan', 'Receive'].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            streams.app.lead.add(LeadIcon.pass);
            streams.app.fling.add(false);
            if (xlead == LeadIcon.dismiss) streams.app.lead.add(LeadIcon.pass);
            Navigator.pop(components.navigator.routeContext ?? context);
          });
    }
    if ([
      'Transactions',
      'Asset',
      'Main',
      'Sub',
      'Restricted',
      'Qualifier',
      'Qualifiersub',
      'Nft',
      'Channel',
    ].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            streams.app.fling.add(false);
            Navigator.pop(components.navigator.routeContext ?? context);
          });
    }
    if (['Createlogin'].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            Navigator.pushReplacementNamed(
              components.navigator.routeContext ?? context,
              '/security/create/setup',
            );
            streams.app.splash.add(false);
          });
    }
    if (['BackupConfirm', 'Backup'].contains(pageTitle)) {
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
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            if (streams.app.scrim.value == true) return;
            Navigator.popUntil(
                components.navigator.routeContext ?? context,
                //ModalRoute.withName('/home') ||
                ModalRoute.withName(components.navigator
                        .nameIsInStack('/security/backup/backupintro')
                    ? '/security/backup/backupintro'
                    : '/home'));
            streams.app.lead
                .add(LeadIcon.pass); // replace with a refresh trigger?
          });
    }

    return IconButton(
        splashRadius: 24,
        icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
        onPressed: () {
          if (streams.app.scrim.value == true) return;
          Navigator.pop(components.navigator.routeContext ?? context);
        });
  }
}
