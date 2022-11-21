import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/pages/security/backup/show.dart';
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
    //listeners.add(
    //    streams.app.triggers.listen((ThresholdTrigger? thresholdTrigger) async {
    //  if (Current.wallet is LeaderWallet &&
    //      thresholdTrigger == ThresholdTrigger.backup &&
    //      !Current.wallet.backedUp) {
    //    await Future.delayed(Duration(milliseconds: 800 * 3));
    //    streams.app.lead.add(LeadIcon.dismiss);
    //    Navigator.of(components.navigator.routeContext!).pushNamed(
    //      '/security/backup',
    //      arguments: {'fadeIn': true},
    //    );
    //    setState(() {});
    //    return;
    //    /// reset till next time they open app?
    //    //streams.app.triggers.add(null);
    //  }
    //}));
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
    final backupCondition = (Current.wallet is LeaderWallet &&
        streams.app.triggers.value == ThresholdTrigger.backup &&
        !Current.wallet.backedUp);
    if (backupCondition) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        streams.app.lead.add(LeadIcon.none);
        Navigator.of(context).pushNamed(
          '/security/backup',
          arguments: {'fadeIn': true},
        );
      });
      //  return BackdropLayers(
      //      back: BlankBack(),
      //      front: FrontCurve(
      //          child: Stack(children: [
      //        components.page.form(
      //          context,
      //          columnWidgets: <Widget>[
      //            instructions(context),
      //            warning(context),
      //          ],
      //          buttons: [
      //            components.buttons.actionButton(
      //              context,
      //              label: 'Show Words',
      //              onPressed: () async {
      //                streams.app.lead.add(LeadIcon.none);
      //                Navigator.of(context).pushNamed(
      //                  '/security/backup',
      //                  arguments: {'fadeIn': true},
      //                );
      //              },
      //            )
      //          ],
      //        ),
      //      ])));
    } else if (services.tutorial.missing.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await showTutorials();
      });
    }
    return HomePage(appContext: appContext);
  }

  Future showTutorials() async {
    for (var tutorial in services.tutorial.missing) {
      streams.app.tutorial.add(tutorial);
      services.tutorial.complete(tutorial);
    }
  }
}
