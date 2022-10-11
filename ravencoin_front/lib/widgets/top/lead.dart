//import 'package:backdrop/backdrop.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
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
  late bool xlead = false;
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
    listeners.add(streams.app.xlead.listen((value) {
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
    if (settingTitle?.startsWith('/settings/') ?? false) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () => streams.app.setting.add('/settings'));
    }
    if (pageTitle == 'Home') {
      return IconButton(
          splashRadius: 24,
          onPressed: () {
            ScaffoldMessenger.of(context).clearSnackBars();
            streams.app.fling.add(true);
          },
          padding: EdgeInsets.only(left: 16),
          icon: SvgPicture.asset('assets/icons/menu/menu.svg'));
    }
    if (pageTitle == '') {
      //return Container();
    }
    if (pageTitle == 'Splash') {
      return Container();
    }
    if (pageTitle == 'Login') {
      return Container();
      //return Container(
      //  height: 24,
      //  padding: EdgeInsets.only(left: 16),
      //  child: SvgPicture.asset(
      //    'assets/icons/menu/menu.svg',
      //    color: AppColors.black38,
      //  ),
      //);
    }
    if (xlead || ['Send', 'Scan', 'Receive'].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            streams.app.fling.add(false);
            if (pageTitle == 'Send') streams.spend.form.add(null);
            if (xlead) streams.app.xlead.add(false);
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
            streams.app.fling.add(false);
            if (pageTitle == 'Transaction') streams.spend.form.add(null);
            Navigator.pop(components.navigator.routeContext ?? context);
          });
    }
    if (['Createlogin'].contains(pageTitle)) {
      return IconButton(
          splashRadius: 24,
          icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacementNamed(
              components.navigator.routeContext ?? context,
              '/security/create/setup',
            );
            streams.app.splash.add(false);
          });
    }
    if (['BackupConfirm', 'Mining'].contains(pageTitle)) {
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
            if (pageTitle == 'Transaction') streams.spend.form.add(null);
            Navigator.popUntil(components.navigator.routeContext ?? context,
                ModalRoute.withName('/home'));
          });
    }
    return IconButton(
        splashRadius: 24,
        icon: Icon(Icons.chevron_left_rounded, color: Colors.white),
        onPressed: () {
          if (pageTitle == 'Transaction') streams.spend.form.add(null);
          Navigator.pop(components.navigator.routeContext ?? context);
        });
  }
}
