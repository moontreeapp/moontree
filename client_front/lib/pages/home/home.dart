import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/services/lookup.dart';
import 'package:client_front/widgets/widgets.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late AppContext appContext = AppContext.wallet;
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];

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
    //listeners.add(pros.settings.changes.listen((Change<Setting> change) {
    //  setState(() {});
    //}));

    listeners.add(streams.app.wallet.refresh.listen((bool value) {
      print('told to Refresh');
      setState(() {});
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
    final bool backupCondition =
        streams.app.triggers.value == ThresholdTrigger.backup &&
            !Current.wallet.backedUp;
    if (backupCondition) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!<String>['Backupintro', 'Backup', 'Backupconfirm']
            .contains(streams.app.page.value)) {
          streams.app.lead.add(LeadIcon.none);
          Navigator.of(context).pushNamed(
            '/security/backup/backupintro',
            arguments: <String, bool>{'fadeIn': true},
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

  Future<void> showTutorials() async {
    for (final TutorialStatus tutorial in services.tutorial.missing) {
      streams.app.tutorial.add(tutorial);
      await services.tutorial.complete(tutorial);
    }
  }
}
