import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/services/lookup.dart';
import 'package:client_front/services/wallet.dart'
    show generateWallet, switchWallet;
import 'package:client_front/theme/theme.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/widgets/bottom/selection_items.dart';
import 'package:client_front/widgets/other/textfield.dart';
import 'package:client_front/widgets/assets/icons.dart';

class PageTitle extends StatefulWidget {
  final bool animate;
  const PageTitle({Key? key, this.animate = true}) : super(key: key);

  @override
  PageTitleState createState() => PageTitleState();

  static Map<String, String> pageMap = const <String, String>{
    'Level': 'User Level',
    'Import_export': 'Import & Export',
    'Change': 'Security',
    'Remove': 'Security',
    'Verify': 'Security',
    'Backupconfirm': 'Backup',
    'Backupkeypair': 'Backup',
    'Channel': 'Create',
    'Nft': 'Create',
    'Main': 'Create',
    'Qualifier': 'Create',
    'Qualifiersub': 'Create',
    'Sub': 'Create',
    'Restricted': 'Create',
    'Createlogin': 'Setup',
    'Login': 'Locked',
    'Backupintro': 'Backup',
  };
  static Map<String, String> pageMapReissue = const <String, String>{
    'Main': 'Reissue',
    'Sub': 'Reissue',
    'Restricted': 'Reissue',
  };
}

class PageTitleState extends State<PageTitle> with TickerProviderStateMixin {
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  bool loading = false;
  bool fullname = false;
  String assetTitle = 'Manage';
  String? settingTitle;
  AppContext appContext = AppContext.login;
  final TextEditingController changeName = TextEditingController();
  late AnimationController controller;
  late Animation<double> animation;
  late AnimationController slowController;
  late Animation<double> slowAnimation;
  final Duration animationDuration = const Duration(milliseconds: 160);
  bool dropDownActive = false;
  List<Wallet> wallets = <Wallet>[];
  late Map<Wallet, List<Security>> walletsSecurities;
  double indicatorWidth = 24;

  @override
  void initState() {
    super.initState();
    initializeWalletSecurities();
    setWalletsSecurities();
    controller = AnimationController(vsync: this, duration: animationDuration);
    slowController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
    slowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(slowController);
    listeners.add(streams.app.loading.listen((bool value) {
      if (value != loading) {
        setState(() {
          loading = value;
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
    listeners.add(pros.settings.changes.listen((Change<Setting> change) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    controller.dispose();
    slowController.dispose();
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  Map<Wallet, List<Security>> initializeWalletSecurities() =>
      walletsSecurities = <Wallet, List<Security>>{
        for (Wallet w in pros.wallets.records) w: <Security>[]
      };

  Future<void> setWallets() async {
    final Iterable<Unspent> unspents = pros.unspents.records
        .where((Unspent e) => e.security == pros.securities.currentCoin);
    wallets = pros.wallets.records
        .where((Wallet w) =>
            unspents.where((Unspent u) => u.walletId == w.id).isNotEmpty)
        .toList();
    if (wallets.isEmpty) {
      wallets = pros.wallets.ordered;
    }
  }

  List<Wallet> getWallets() => wallets.isEmpty ||
          (wallets.length == 1 && wallets.first == Current.wallet)
      ? pros.wallets.ordered
      : wallets;

  Future<void> setWalletsSecurities() async {
    if (!services.developer.developerMode) {
      wallets = pros.wallets.ordered;
      return;
    }
    final List<Unspent> unspents = pros.unspents.records
        .where((Unspent e) => pros.securities.coins.contains(e.security))
        .toList();
    for (final Wallet w in pros.wallets.records) {
      if ((walletsSecurities[w] ?? <Security>[]).isEmpty) {
        walletsSecurities[w] = pros.securities.coins
            .where((Security s) => unspents
                .where((Unspent u) => u.walletId == w.id && u.security == s)
                .isNotEmpty)
            .toList();
      } else {
        // to remember while app is open
        walletsSecurities[w] = (walletsSecurities[w]! +
                pros.securities.coins
                    .where((Security s) => unspents
                        .where((Unspent u) =>
                            u.walletId == w.id && u.security == s)
                        .isNotEmpty)
                    .toList())
            .toSet()
            .toList();
      }

      /// for testing
      //walletsSecurities[w] = [];
      //walletsSecurities[w]!.add(pros.securities.RVNt);
      //walletsSecurities[w]!.add(pros.securities.EVR);
      //walletsSecurities[w]!.add(pros.securities.RVN);
      //walletsSecurities[w]!.add(pros.securities.EVRt);
    }
    wallets = <Wallet>[];
    final Security currentCrypto = pros.securities.currentCoin;
    for (final MapEntry<Wallet, List<Security>> ws
        in walletsSecurities.entries) {
      if (ws.value.contains(currentCrypto)) {
        wallets.add(ws.key);
      }
    }
    wallets = pros.wallets.order(wallets);
    setHoldingsIndicatorsSize();
  }

  List<Widget> holdingsIndicators(Wallet wallet) {
    final List<Widget> ret = <Widget>[];
    if (services.developer.developerMode) {
      for (final Security s in pros.securities.coins) {
        if (walletsSecurities[wallet]!.contains(s)) {
          ret.add(Container(
              padding: EdgeInsets.only(left: ret.length * 12),
              child: icons.crypto(s, height: 24, width: 24, circled: true)));
        }
      }
    }
    return ret.reversed.toList();
  }

  void setHoldingsIndicatorsSize() {
    indicatorWidth = 24;
    if (services.developer.developerMode) {
      indicatorWidth = 24 +
          (walletsSecurities.values.map((List<Security> e) => e.length).max *
              12);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (streams.app.page.value == 'Splash') {
      if (widget.animate) {
        slowController.forward(from: 0.0);
        return FadeTransition(
            opacity: slowAnimation, child: const Text('Welcome'));
      }
      return const Text('Welcome');
    }
    if (loading || <String>['main', ''].contains(streams.app.page.value)) {
      return const Text('');
    }
    FittedBox wrap(String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(x,
            style: Theme.of(context).textTheme.headline2!.copyWith(
                  color: AppColors.white,
                  fontWeight:
                      x.length >= 25 ? FontWeights.bold : FontWeights.semiBold,
                )));
    controller.forward();
    FittedBox assetWrap(String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: GestureDetector(
            onTap: () async {
              controller.reverse();
              await Future<void>.delayed(animationDuration);
              setState(() => fullname = !fullname);
            },
            child: FadeTransition(
                opacity: animation,
                child: Text(x,
                    style: Theme.of(context).textTheme.headline2!.copyWith(
                          color: AppColors.white,
                          fontWeight: x.length >= 25
                              ? FontWeights.bold
                              : FontWeights.semiBold,
                        )))));
    if (<String>['Asset', 'Transactions'].contains(streams.app.page.value)) {
      return assetWrap(fullname ? assetTitle : assetName(assetTitle));
    }
    fullname = false;
    return walletNumber() ??
        wrap((streams.reissue.form.value != null
                ? PageTitle.pageMapReissue[streams.app.page.value]
                : null) ??
            PageTitle.pageMap[streams.app.page.value] ??
            (streams.app.page.value == 'Home'
                ? /*appContext.name.toTitleCase()*/ ' '
                : streams.app.page.value));
  }

  String assetName(String given) {
    if (given == pros.securities.RVN.symbol) {
      return 'Ravencoin';
    }
    if (given == pros.securities.EVR.symbol) {
      return 'Evrmore';
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
    if (streams.app.page.value != 'Home') {
      return null;
    }
    if (pros.wallets.isNotEmpty) {
      if (settingTitle != null && settingTitle == '/settings/import_export') {
        return const Text('Import & Export');
      } else if (settingTitle != null && settingTitle == '/settings/settings') {
        return const Text('Settings');
      } else if (settingTitle != null &&
          (pros.wallets.length > 1 ||
              <FeatureLevel>[FeatureLevel.normal, FeatureLevel.expert].contains(
                  pros.settings.primaryIndex
                      .getOne(SettingName.mode_dev)
                      ?.value))) {
        return walletDropDown();
      } else if (appContext == AppContext.wallet) {
        return GestureDetector(
            onDoubleTap: () async {
              bool next = false;
              for (final Wallet wallet
                  in pros.wallets.ordered + pros.wallets.ordered) {
                // why twice?
                if (next) {
                  return switchWallet(wallet.id, context);
                }
                if (Current.walletId == wallet.id) {
                  next = true;
                }
              }
            },
            child: Text(pros.wallets.currentWalletName,
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: AppColors.white)));
      } else if (appContext == AppContext.manage) {
        return Text(pros.wallets.currentWalletName,
            style: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(color: AppColors.white));
      } else if (appContext == AppContext.swap) {
        return Text(pros.wallets.currentWalletName,
            style: Theme.of(context)
                .textTheme
                .headline2!
                .copyWith(color: AppColors.white));
      }
    }

    return null;
  }

  /// produces a snackbar with options - has to be a snackbar because the front
  /// layer is down, that's where anything like a bottom modal popup would be,
  /// but there's not enough room on the front layer for that.
  Widget walletDropDown() => GestureDetector(
      onTap: () async {
        if (!dropDownActive) {
          dropDownActive = true;
          setWalletsSecurities();
          await walletSelection();
        }
      },
      child: Row(
        children: <Widget>[
          Text(pros.wallets.currentWalletName,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: AppColors.white)),
          const Icon(Icons.expand_more_rounded, color: Colors.white),
        ],
      ));

  Future<void> walletSelection() async => SimpleSelectionItems(
        components.routes.routeContext!,
        then: () => dropDownActive = false,
        items: <Widget>[
              if (services.developer.developerMode == true)
                ListTile(
                  visualDensity: VisualDensity.compact,
                  onTap: () async {
                    Navigator.pop(components.routes.routeContext!);
                    await components.loading
                        .screen(message: 'Creating Wallet', playCount: 3);
                    final String walletId = await generateWallet();
                    await switchWallet(walletId, context);
                  },
                  leading: Container(
                      width: indicatorWidth,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.add, color: AppColors.primary)),
                  title: Text('New Wallet',
                      style: Theme.of(context).textTheme.bodyText1),
                  trailing: getWallets().equals(pros.wallets.ordered)
                      ? null
                      : TextButton(
                          onPressed: () async {
                            Navigator.pop(components.routes.routeContext!);
                            setState(() {
                              dropDownActive = false;
                              wallets = pros.wallets.ordered;
                            });
                            await walletSelection();
                            await Future<void>.delayed(
                                const Duration(milliseconds: 100));
                            streams.app.scrim.add(false);
                          },
                          child: Text(
                            'Show All',
                            style: Theme.of(context)
                                .textTheme
                                .bodyText1!
                                .copyWith(color: AppColors.primary),
                          )),
                ),
              if (services.developer.advancedDeveloperMode == true)
                ListTile(
                  visualDensity: VisualDensity.compact,
                  onTap: () async {
                    Navigator.pop(components.routes.routeContext!);
                    final String walletId =
                        await generateWallet(walletType: WalletType.single);
                    await switchWallet(walletId, context);
                  },
                  leading: Container(
                      width: indicatorWidth,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.add, color: AppColors.primary)),
                  title: Text('New Single Wallet',
                      style: Theme.of(context).textTheme.bodyText1),
                )
            ] +
            <Widget>[
              for (Wallet wallet in getWallets())
                ListTile(
                    visualDensity: VisualDensity.compact,
                    onTap: () async {
                      Navigator.pop(components.routes.routeContext!);
                      if (wallet.id != Current.walletId) {
                        await switchWallet(wallet.id, context);
                      }
                    },
                    leading: walletsSecurities[wallet] == null ||
                            walletsSecurities[wallet]!.isEmpty ||
                            !services.developer.developerMode
                        ? const Icon(
                            Icons.account_balance_wallet_rounded,
                            color: AppColors.primary,
                          )
                        : SizedBox(
                            width: indicatorWidth,
                            child: Stack(children: holdingsIndicators(wallet))),
                    title: Text(wallet.name,
                        style: Theme.of(context).textTheme.bodyText1),
                    // awaiting design..........
                    trailing: !services.developer.developerMode
                        ? null
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              IconButton(
                                icon: const Icon(
                                  Icons.edit_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () async {
                                  changeName.text = wallet.name;
                                  await components.message.giveChoices(
                                      components.routes.routeContext!,
                                      title: 'Change Name',
                                      content:
                                          'What should this wallet be called?',
                                      child: Container(
                                          padding: const EdgeInsets.only(
                                              top: 16, bottom: 16),
                                          child: TextFieldFormatted(
                                            maxLength: 10,
                                            controller: changeName,
                                          )),
                                      behaviors: <String, void Function()>{
                                        'cancel': () => Navigator.pop(
                                            components.routes.routeContext!),
                                        'submit': () async {
                                          if (changeName.text != '') {
                                            if (wallet is LeaderWallet) {
                                              await pros.wallets
                                                  .save(LeaderWallet.from(
                                                wallet,
                                                name: changeName.text,
                                                seed: await wallet.seed,
                                              ));
                                            } else if (wallet is SingleWallet) {
                                              await pros.wallets
                                                  .save(SingleWallet.from(
                                                wallet,
                                                name: changeName.text,
                                                //getWif: await wallet.getWif,
                                              ));
                                            }
                                            initializeWalletSecurities();
                                            setWalletsSecurities();
                                          }
                                          Navigator.pop(
                                              components.routes.routeContext!);
                                          Navigator.pop(
                                              components.routes.routeContext!);
                                          setState(() {});
                                        }
                                      });
                                },
                              ),
                              if (pros.wallets.records.length > 1)
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_forever_rounded,
                                    color: AppColors.primary,
                                  ),
                                  onPressed: () async {
                                    await components.message.giveChoices(
                                        components.routes.routeContext!,
                                        title: 'DANGER!',
                                        content:
                                            'WARNING: You are about to delete a wallet. This action cannot be undone! Are you sure you want to delete it?',
                                        behaviors: <String, void Function()>{
                                          'CANCEL': () => Navigator.pop(
                                              components.routes.routeContext!),
                                          'DELETE FOREVER': () async =>
                                              components.message.giveChoices(
                                                components.routes.routeContext!,
                                                title: 'CONFIRM DELETE',
                                                content:
                                                    'To delete ${wallet.name} you will need to authenticate.',
                                                //child:
                                                behaviors: <String,
                                                    void Function()>{
                                                  'CANCEL': () {
                                                    Navigator.pop(components
                                                        .routes.routeContext!);
                                                    Navigator.pop(components
                                                        .routes.routeContext!);
                                                  },
                                                  'OK': () async {
                                                    Navigator.pop(components
                                                        .routes.routeContext!);
                                                    Navigator.pop(components
                                                        .routes.routeContext!);
                                                    Navigator.pop(components
                                                        .routes.routeContext!);
                                                    Navigator.pushNamed(
                                                        components.routes
                                                            .routeContext!,
                                                        '/security/security',
                                                        arguments: <String,
                                                            Object>{
                                                          'buttonLabel':
                                                              'Delete ${wallet.name} Forever',
                                                          'onSuccess':
                                                              () async {
                                                            Navigator.pop(components
                                                                .routes
                                                                .routeContext!);
                                                            if (wallet.id ==
                                                                Current
                                                                    .walletId) {
                                                              await switchWallet(
                                                                  pros.wallets
                                                                      .records
                                                                      .where((Wallet
                                                                              w) =>
                                                                          w.id !=
                                                                          wallet
                                                                              .id)
                                                                      .first
                                                                      .id,
                                                                  context);
                                                            }
                                                            await pros.wallets
                                                                .remove(wallet);
                                                            wallets = pros
                                                                .wallets
                                                                .ordered;
                                                            initializeWalletSecurities();
                                                            setWalletsSecurities();
                                                          }
                                                        });
                                                  }
                                                },
                                              )
                                        });
                                  },
                                ),
                            ],
                          ))
            ],
      ).build();
}
