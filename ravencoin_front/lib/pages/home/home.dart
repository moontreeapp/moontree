import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
    final backupCondition =
        (streams.app.triggers.value == ThresholdTrigger.backup &&
            !Current.wallet.backedUp);
    if (backupCondition) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!['Backupintro', 'Backup', 'BackupConfirm']
            .contains(streams.app.page.value)) {
          streams.app.lead.add(LeadIcon.none);
          Navigator.of(context).pushNamed(
            '/security/backup/backupintro',
            arguments: {'fadeIn': true},
          );
        }
      });
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
