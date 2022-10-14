import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart'
    show generateWallet, switchWallet;
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/widgets/bottom/selection_items.dart';
import 'package:ravencoin_front/widgets/other/textfield.dart';

class PageTitle extends StatefulWidget {
  final bool animate;
  PageTitle({Key? key, this.animate = true}) : super(key: key);

  @override
  PageTitleState createState() => PageTitleState();

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
    'BackupKeypair': 'Backup',
    'Channel': 'Create',
    'Nft': 'Create',
    'Main': 'Create',
    'Qualifier': 'Create',
    'Qualifiersub': 'Create',
    'Sub': 'Create',
    'Restricted': 'Create',
    'Createlogin': 'Setup',
    'Login': 'Locked',
  };
  static Map<String, String> pageMapReissue = const {
    'Main': 'Reissue',
    'Sub': 'Reissue',
    'Restricted': 'Reissue',
  };
}

class PageTitleState extends State<PageTitle> with TickerProviderStateMixin {
  List listeners = [];
  bool loading = false;
  bool fullname = false;
  String pageTitle = 'Home';
  String assetTitle = 'Manage';
  String? settingTitle = null;
  AppContext appContext = AppContext.login;
  final TextEditingController changeName = TextEditingController();
  late AnimationController controller;
  late Animation<double> animation;
  late AnimationController slowController;
  late Animation<double> slowAnimation;
  final Duration animationDuration = Duration(milliseconds: 160);
  bool dropDownActive = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: animationDuration);
    slowController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    animation = Tween(begin: 0.0, end: 1.0).animate(controller);
    slowAnimation = Tween(begin: 0.0, end: 1.0).animate(slowController);
    listeners.add(streams.app.loading.listen((bool value) {
      if (value != loading) {
        setState(() {
          loading = value;
        });
      }
    }));
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
    listeners.add(pros.settings.changes.listen((Change change) {
      setState(() {});
    }));
  }

  @override
  void dispose() {
    controller.dispose();
    slowController.dispose();
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
    if (pageTitle == 'Splash') {
      if (widget.animate) {
        slowController.forward(from: 0.0);
        return FadeTransition(opacity: slowAnimation, child: Text('Welcome'));
      }
      return Text('Welcome');
    }
    if (loading || ['main', ''].contains(pageTitle)) {
      return Text('');
    }
    var wrap = (String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(x,
            style: Theme.of(context).textTheme.headline2!.copyWith(
                  color: AppColors.white,
                  fontWeight:
                      x.length >= 25 ? FontWeights.bold : FontWeights.semiBold,
                )));
    controller.forward();
    var assetWrap = (String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: GestureDetector(
            onTap: () async {
              controller.reverse();
              await Future.delayed(animationDuration);
              setState(() {
                fullname = !fullname;
              });
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
    if (['Asset', 'Transactions'].contains(pageTitle)) {
      return assetWrap(fullname ? assetTitle : assetName(assetTitle));
    }
    fullname = false;
    return walletNumber() ??
        wrap(PageTitle.settingsMap[settingTitle] ??
            (streams.reissue.form.value != null
                ? PageTitle.pageMapReissue[pageTitle]
                : null) ??
            PageTitle.pageMap[pageTitle] ??
            (pageTitle == 'Home'
                ? /*appContext.name.toTitleCase()*/ ' '
                : pageTitle));
  }

  String assetName(String given) {
    if (given == pros.securities.RVN.symbol) {
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
    if (pros.wallets.length > 0) {
      if (settingTitle != null &&
          (pros.wallets.length > 1 ||
              pros.settings.primaryIndex.getOne(SettingName.Mode_Dev)?.value ==
                  true)) {
        return walletDropDown();
      } else if (appContext == AppContext.wallet) {
        return GestureDetector(
            onDoubleTap: () async {
              var next = false;
              var walletId;
              for (Wallet wallet
                  in pros.wallets.ordered + pros.wallets.ordered) {
                if (next) {
                  walletId = wallet.id;
                  break;
                }
                if (Current.walletId == wallet.id) {
                  next = true;
                }
              }
              await switchWallet(walletId);
            },
            child: Text(pros.wallets.currentWalletName,
                style: Theme.of(context)
                    .textTheme
                    .headline2!
                    .copyWith(color: AppColors.white)));
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
          await SimpleSelectionItems(
            components.navigator.routeContext!,
            then: () => dropDownActive = false,
            items: [
                  if (pros.settings.developerMode == true)
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: () async {
                        Navigator.pop(components.navigator.routeContext!);
                        final walletId = await generateWallet();
                        await switchWallet(walletId);
                      },
                      leading: Icon(Icons.add, color: AppColors.primary),
                      title: Text('New Wallet',
                          style: Theme.of(context).textTheme.bodyText1),
                    ),
                  if (pros.settings.developerMode == true)
                    ListTile(
                      visualDensity: VisualDensity.compact,
                      onTap: () async {
                        Navigator.pop(components.navigator.routeContext!);
                        final walletId =
                            await generateWallet(walletType: WalletType.single);
                        await switchWallet(walletId);
                      },
                      leading: Icon(Icons.add, color: AppColors.primary),
                      title: Text('New Single Wallet',
                          style: Theme.of(context).textTheme.bodyText1),
                    )
                ] +
                [
                  for (Wallet wallet in pros.wallets.ordered)
                    ListTile(
                        visualDensity: VisualDensity.compact,
                        onTap: () async {
                          Navigator.pop(components.navigator.routeContext!);
                          if (wallet.id != Current.walletId) {
                            await switchWallet(wallet.id);
                          }
                        },
                        leading: Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                        ),
                        title: Text(wallet.name,
                            style: Theme.of(context).textTheme.bodyText1),
                        // awaiting design..........
                        trailing: !pros.settings.developerMode
                            ? null
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_rounded,
                                      color: AppColors.primary,
                                    ),
                                    onPressed: () async {
                                      changeName.text = wallet.name;
                                      await components.message.giveChoices(
                                          components.navigator.routeContext!,
                                          title: 'Change Name',
                                          content:
                                              'What should this wallet be called?',
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  top: 16, bottom: 16),
                                              child: TextFieldFormatted(
                                                controller: changeName,
                                              )),
                                          behaviors: {
                                            'cancel': () => Navigator.pop(
                                                components
                                                    .navigator.routeContext!),
                                            'submit': () async {
                                              if (changeName.text != '') {
                                                if (wallet is LeaderWallet) {
                                                  await pros.wallets
                                                      .save(LeaderWallet.from(
                                                    wallet,
                                                    name: changeName.text,
                                                    seed: await wallet.seed,
                                                  ));
                                                } else if (wallet
                                                    is SingleWallet) {
                                                  await pros.wallets
                                                      .save(SingleWallet.from(
                                                    wallet,
                                                    name: changeName.text,
                                                    //getWif: await wallet.getWif,
                                                  ));
                                                }
                                              }

                                              Navigator.pop(components
                                                  .navigator.routeContext!);
                                              Navigator.pop(components
                                                  .navigator.routeContext!);
                                              setState(() {});
                                            }
                                          });
                                    },
                                  ),
                                  if (pros.wallets.records.length > 1)
                                    IconButton(
                                      icon: Icon(
                                        Icons.delete_forever_rounded,
                                        color: AppColors.primary,
                                      ),
                                      onPressed: () async {
                                        await components.message.giveChoices(
                                            components.navigator.routeContext!,
                                            title: 'DANGER!',
                                            content:
                                                'WARNING: You are about to delete a wallet. This action cannot be undone! Are you sure you want to delete it?',
                                            behaviors: {
                                              'CANCEL': () => Navigator.pop(
                                                  components
                                                      .navigator.routeContext!),
                                              'DELETE FOREVER': () async =>
                                                  await components.message
                                                      .giveChoices(
                                                    components.navigator
                                                        .routeContext!,
                                                    title: 'CONFIRM DELETE',
                                                    content:
                                                        "To delete ${wallet.name} you will need to authenticate.",
                                                    //child:
                                                    behaviors: {
                                                      'CANCEL': () {
                                                        Navigator.pop(components
                                                            .navigator
                                                            .routeContext!);
                                                        Navigator.pop(components
                                                            .navigator
                                                            .routeContext!);
                                                      },
                                                      'OK': () async {
                                                        Navigator.pop(components
                                                            .navigator
                                                            .routeContext!);
                                                        Navigator.pop(components
                                                            .navigator
                                                            .routeContext!);
                                                        Navigator.pop(components
                                                            .navigator
                                                            .routeContext!);
                                                        Navigator.pushNamed(
                                                            components.navigator
                                                                .routeContext!,
                                                            '/security/security',
                                                            arguments: {
                                                              'buttonLabel':
                                                                  'Delete ${wallet.name} Forever',
                                                              'onSuccess':
                                                                  () async {
                                                                Navigator.pop(
                                                                    components
                                                                        .navigator
                                                                        .routeContext!);
                                                                if (wallet.id ==
                                                                    Current
                                                                        .walletId) {
                                                                  await switchWallet(pros
                                                                      .wallets
                                                                      .records
                                                                      .where((w) =>
                                                                          w.id !=
                                                                          wallet
                                                                              .id)
                                                                      .first
                                                                      .id);
                                                                }
                                                                await pros
                                                                    .wallets
                                                                    .remove(
                                                                        wallet);
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
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(pros.wallets.currentWalletName,
              style: Theme.of(context)
                  .textTheme
                  .headline2!
                  .copyWith(color: AppColors.white)),
          Icon(Icons.expand_more_rounded, color: Colors.white),
        ],
      ));
}
