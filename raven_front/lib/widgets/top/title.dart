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
  late String assetTitle = 'Manage';
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
    listeners.add(streams.app.asset.listen((String? value) {
      if (appContext == AppContext.manage &&
          value != assetTitle &&
          value != null) {
        setState(() {
          assetTitle = value;
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

  Widget body() => ['main', ''].contains(pageTitle)
      ? Text('')
      : walletNumber ??
          FittedBox(
              fit: BoxFit.fitWidth,
              child: Text(
                  const {
                        '/settings/import_export': 'Import / Export',
                        '/settings/settings': 'Settings',
                      }[settingTitle] ??
                      const {
                        'Send': 'Send',
                        'Import_export': 'Import / Export',
                        'Change': 'Security',
                        'Remove': 'Security',
                        'Verify': 'Security',
                        'Receive': 'Receive',
                        'Channel': 'Create',
                        'Nft': 'Create',
                        'Main': 'Create',
                        'Qualifier': 'Create',
                        'Qualifiersub': 'Create',
                        'Sub': 'Create',
                        'Restricted': 'Create',
                      }[pageTitle] ??
                      {
                        'Transactions': ((streams.spend.form.value?.symbol ??
                                    'RVN') ==
                                'RVN')
                            ? 'Ravencoin'
                            : streams.spend.form.value!.symbol!.endsWith('!')
                                ? streams.spend.form.value!.symbol!
                                    .replaceAll('!', '') //' (Admin)')
                                : streams.spend.form.value?.symbol,
                        'Asset': assetTitle.split('/').last,
                      }[pageTitle] ??
                      (pageTitle == 'Wallet'
                          ? appContext.enumString.toTitleCase()
                          : pageTitle),
                  style: Theme.of(context).pageTitle));

  Widget? get walletNumber {
    if (pageTitle != 'Wallet') {
      return null;
    }
    if (res.wallets.length > 1) {
      print(settingTitle);
      if (settingTitle == 'open') {
        return GestureDetector(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('Wallet ' + res.wallets.currentWalletName + ' ',
                    style: Theme.of(context).pageTitle),
                Icon(Icons.expand_more_rounded, color: Colors.white),
              ],
            ));
      } else if (appContext == AppContext.wallet) {
        return Text('Wallet ' + res.wallets.currentWalletName + ' ',
            style: Theme.of(context).pageTitle);
      }
    }

    return null;
  }
}
