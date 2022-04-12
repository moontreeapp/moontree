import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/components/components.dart';

class PageTitle extends StatefulWidget {
  PageTitle({Key? key}) : super(key: key);

  @override
  _PageTitleState createState() => _PageTitleState();

  static Map<String, String> settingsMap = const {
    '/settings/import_export': 'Import / Export',
    '/settings/settings': 'Settings',
  };
  static Map<String, String> pageMap = const {
    'Level': 'User Level',
    'Import_export': 'Import / Export',
    'Change': 'Security',
    'Remove': 'Security',
    'Verify': 'Security',
    'BackupConfirm': 'Backup',
    'Channel': 'Create',
    'Nft': 'Create',
    'Main': 'Create',
    'Qualifier': 'Create',
    'Qualifiersub': 'Create',
    'Sub': 'Create',
    'Restricted': 'Create',
    'Login': 'Unlock',
  };
  static Map<String, String> pageMapReissue = const {
    'Main': 'Reissue',
    'Sub': 'Reissue',
    'Restricted': 'Reissue',
  };
}

class _PageTitleState extends State<PageTitle> {
  late List listeners = [];
  late String pageTitle = 'Home';
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
    listeners.add(streams.app.manage.asset.listen((String? value) {
      if (appContext == AppContext.manage &&
          value != assetTitle &&
          value != null) {
        setState(() {
          assetTitle = value;
        });
      }
    }));
    listeners.add(streams.app.wallet.asset.listen((String? value) {
      if (appContext == AppContext.wallet &&
          value != assetTitle &&
          value != null) {
        setState(() {
          assetTitle = value;
        });
      }
    }));
    listeners.add(res.settings.changes.listen((Change change) {
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
    return body();
  }

  Widget body() {
    if (['main', ''].contains(pageTitle)) {
      return Text('');
    }
    var wrap = (String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(x,
            style: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(color: AppColors.white)));
    if (['Asset', 'Transactions'].contains(pageTitle)) {
      return wrap(assetName(assetTitle));
    }
    return walletNumber() ??
        wrap(PageTitle.settingsMap[settingTitle] ??
            (streams.create.form.value?.minQuantity != null
                ? PageTitle.pageMapReissue[pageTitle]
                : null) ??
            PageTitle.pageMap[pageTitle] ??
            (pageTitle == 'Home'
                ? appContext.enumString.toTitleCase()
                : pageTitle));
  }

  String assetName(String given) {
    if (given == 'RVN') {
      return 'Ravencoin';
    }
    if (given.contains('~')) {
      return given.toLowerCase().split('~').last.toTitleCase();
    }
    if (given.contains('#')) {
      return given.toLowerCase().split('#').last.toTitleCase();
    }
    return given
        .toLowerCase()
        .split('/')
        .last
        .replaceAll('#', '')
        .replaceAll('~', '')
        .replaceAll(r'$', '')
        .replaceAll('!', '')
        .toTitleCase();
  }

  Widget? walletNumber() {
    if (pageTitle != 'Home') {
      return null;
    }
    if (res.wallets.length > 1) {
      if (settingTitle != null) {
        return walletDropDown();
      } else if (appContext == AppContext.wallet) {
        return Text('Wallet ' + res.wallets.currentWalletName + ' ',
            style: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(color: AppColors.white));
      }
    }

    return null;
  }

  Widget walletDropDown() => GestureDetector(
      onTap: () {
        if (components.navigator.isSnackbarActive) {
          components.navigator.isSnackbarActive = false;
          ScaffoldMessenger.of(context).clearSnackBars();
        } else {
          components.navigator.isSnackbarActive = true;
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
                elevation: 0,
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                )),
                duration: Duration(seconds: 60),
                content: Container(
                    child: ListView(shrinkWrap: true, children: <Widget>[
                  for (Wallet wallet in res.wallets)
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: () {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        res.settings.setCurrentWalletId(wallet.id);
                        streams.app.setting.add(null);
                      },
                      leading: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text('Wallet ' + wallet.name,
                          style: Theme.of(context).textTheme.bodyText1),
                    )
                ])),
              ))
              .closed
              .then((SnackBarClosedReason reason) {
            components.navigator.isSnackbarActive = false;
          });
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text('Wallet ' + res.wallets.currentWalletName + ' ',
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: AppColors.white)),
          Icon(Icons.expand_more_rounded, color: Colors.white),
        ],
      ));
}
