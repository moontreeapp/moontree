import 'package:flutter/material.dart';
import 'package:raven_back/extensions/string.dart';
import 'package:raven_back/extensions/object.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/theme/extensions.dart';

class PageTitle extends StatefulWidget {
  PageTitle({Key? key}) : super(key: key);

  @override
  _PageTitleState createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> {
  late List listeners = [];
  late String pageTitle = 'Wallet';
  late String? settingTitle = null;
  late AppContext appContext = AppContext.wallet;
  final changeName = TextEditingController();

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.page.listen((String value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
    listeners.add(streams.app.context.listen((AppContext value) {
      if (value != appContext) {
        setState(() {
          appContext = value;
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
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(
      {
            '/settings/import_export': 'Import / Export',
            '/settings/settings': 'Settings',
          }[settingTitle] ??
          {
            '': '',
            'main': '',
            'Send': '',
            'Import_export': 'Import / Export',
            'Change': 'Security',
            'Remove': 'Security',
            'Verify': 'Security',
            'Receive': 'Receive',
            'Transactions':
                ((streams.spend.form.value?.symbol ?? 'RVN') == 'RVN')
                    ? 'Ravencoin'
                    : streams.spend.form.value?.symbol,
          }[pageTitle] ??
          (pageTitle == 'Wallet'
              ? appContext.enumString.toTitleCase()
              : pageTitle),
      style: Theme.of(context).pageTitle);
}
