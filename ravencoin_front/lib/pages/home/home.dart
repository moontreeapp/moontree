import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppContext appContext = AppContext.wallet;
  late List<StreamSubscription> listeners = [];

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.context.listen((AppContext value) {
      if (value != appContext) {
        if (value == AppContext.wallet &&
            streams.app.manage.asset.value != null) {
          streams.app.manage.asset.add(null);
        } else if (value == AppContext.manage &&
            streams.app.wallet.asset.value != null) {
          streams.app.wallet.asset.add(null);
        }
        setState(() {
          appContext = value;
        });
      }
    }));
    listeners.add(pros.settings.changes.listen((Change change) {
      setState(() {});
    }));
    listeners.add(
        streams.app.triggers.listen((ThresholdTrigger? thresholdTrigger) async {
      if (Current.wallet is LeaderWallet &&
          thresholdTrigger == ThresholdTrigger.backup &&
          !Current.wallet.backedUp) {
        await Future.delayed(Duration(milliseconds: 800 * 3));
        streams.app.xlead.add(true);
        Navigator.of(components.navigator.routeContext!).pushNamed(
          '/security/backup',
          arguments: {'fadeIn': true},
        );
        setState(() {});
        return;

        /// reset till next time they open app?
        //streams.app.triggers.add(null);
      }
    }));
    listeners.add(streams.app.wallet.refresh.listen((bool value) {
      print('told to Refresh');
      setState(() {});
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
    //services.tutorial.clear();
    //if (services.tutorial.missing.isNotEmpty) {
    //  WidgetsBinding.instance.addPostFrameCallback((_) async {
    //    await showTutorials();
    //  });
    //}
    return HomePage(appContext: appContext);
  }

  Future showTutorials() async {
    var x = 0;
    for (var tutorial in services.tutorial.missing) {
      print(x);
      x += 1;
      streams.app.scrim.add(true);
      //services.tutorial.complete(TutorialStatus.blockchain);
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            streams.app.scrim.add(true);
            return AlertDialog(
                title: Text('Password Not Recognized'),
                content: Text(
                    'Password does not match the password used at the time of encryption.'));
          }).then((value) => streams.app.scrim.add(false));
    }
  }
}
