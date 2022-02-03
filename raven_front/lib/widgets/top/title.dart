import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';

class PageTitle extends StatefulWidget {
  PageTitle({Key? key}) : super(key: key);

  @override
  _PageTitleState createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> {
  late String pageTitle = 'Wallet';
  late String? settingTitle = null;
  late List listeners = [];
  final changeName = TextEditingController();

  @override
  void initState() {
    super.initState();
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
            'Transactions':
                ((streams.spend.form.value?.symbol ?? 'RVN') == 'RVN')
                    ? 'Ravencoin'
                    : streams.spend.form.value?.symbol,
          }[pageTitle] ??
          ((pageTitle != 'Wallet' || res.accounts.data.length <= 1)
              ? pageTitle
              : 'Wallet'),
      style: Theme.of(context).pageTitle);
}
