import 'dart:async';

import 'package:flutter/material.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppContext appContext = AppContext.wallet;
  late List<StreamSubscription> listeners = [];
  bool importing = false;

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
    listeners.add(res.settings.changes.listen((Change change) {
      setState(() {});
    }));
    //listeners.add(streams.import.attempt.listen((request) {
    //  if (request != null) {
    //    setState(() {
    //      importing = true;
    //    });
    //  }
    //}));
    listeners.add(streams.app.snack.listen((Snack? snack) {
      if (snack != null && snack.message == 'Sucessful Import') {
        setState(() {
          importing = true;
        });
      }
    }));
    listeners.add(
        streams.app.triggers.listen((ThresholdTrigger? thresholdTrigger) async {
      if (Current.wallet is LeaderWallet &&
          thresholdTrigger == ThresholdTrigger.backup &&
          !(Current.wallet as LeaderWallet).backedUp) {
        await Future.delayed(Duration(milliseconds: 800));
        streams.app.xlead.add(true);
        Navigator.of(components.navigator.routeContext!).pushNamed(
          '/security/backup',
          arguments: {'fadeIn': true},
        );
        return;
        //setState(() {});
        /// reset till next time they open app?
        //streams.app.triggers.add(null);
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
    print('addresses ${Current.wallet.addresses.length}');
    var x =
        HomePage(appContext: appContext, importing: importing ? true : false);
    importing = false;
    return x;
  }
}
