import 'dart:async';
import 'package:client_front/application/containers/front/cubit.dart';
import 'package:client_front/application/infrastructure/search/cubit.dart';
import 'package:client_front/presentation/utils/animation.dart';
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show generateWallet, switchWallet;
import 'package:client_front/application/app/title/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/widgets/bottom/selection_items.dart';
import 'package:client_front/presentation/widgets/other/textfield.dart';
import 'package:client_front/presentation/widgets/assets/icons.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/services/services.dart'
    show sail, screen;

class PageTitle extends StatefulWidget {
  final bool showWalletChange;
  const PageTitle({Key? key, this.showWalletChange = false}) : super(key: key);

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
  //SingleTickerProviderStateMixin
  late List<StreamSubscription<dynamic>> listeners =
      <StreamSubscription<dynamic>>[];
  bool loading = false;
  bool fullname = false;
  String assetTitle = 'Manage';
  String? settingTitle;
  AppContext appContext = AppContext.login;
  final TextEditingController changeName = TextEditingController();

  /// after testing the animations on page change, fade out and fade in, are too
  /// distracting. so we're removing this. but we may want to retain the slow
  /// fade in on the login screens...
  //late AnimationController controller;
  //late Animation<double> animate;
  late AnimationController slowController;
  late Animation<double> slowAnimation;
  bool dropDownActive = false;
  List<Wallet> wallets = <Wallet>[];
  late Map<Wallet, List<Security>> walletsSecurities;
  double indicatorWidth = 24;
  late TitleCubit cubit;

  @override
  void initState() {
    super.initState();
    cubit = components.cubits.title;
    slowController =
        AnimationController(vsync: this, duration: animation.slowFadeDuration);
    slowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: slowController, curve: Curves.easeInOutCubic));
    slowController.forward();
    //controller =
    //    AnimationController(vsync: this, duration: animation.fadeDuration);
    //animate = Tween<double>(begin: 0.0, end: 1.0).animate(
    //    CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic));

    /*
    initializeWalletSecurities();
    setWalletsSecurities();
    //controller = AnimationController(vsync: this, duration: animationDuration);
    animation = Tween<double>(begin: 0.0, end: 1.0).animate(controller);
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
    */
  }

  @override
  void dispose() {
    //controller.dispose();
    //slowController.dispose();
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

  List<Widget> walletOptions({
    BuildContext? context,
    Function? onTap,
    Function(ChainNet)? first,
    Function? second,
  }) =>
      <Widget>[
        for (final Wallet wallet in pros.wallets.ordered)
          ListTile(
            onTap: () async {
              if (onTap != null) {
                onTap();
              }
              await switchWallet(wallet.id);
              setState(() {});
              sail.menu(open: false);
              sail.to(components.cubits.location.state.path,
                  replaceOverride: true);
              return;
            },
            // todo: show chain icons for what blockchains this wallet has assets on here
            leading:
                //Icon(Icons.wallet_rounded,
                //    color: wallet == Current.wallet ? AppColors.primary : null),
                Container(
                    height: 24,
                    child: SvgPicture.asset(
                        'assets/icons/custom/mobile/wallet${wallet == Current.wallet ? '-active' : ''}.svg')),
            title: Text(wallet.name,
                style: Theme.of(context ?? components.routes.context!)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.black87)),
            trailing: wallet == Current.wallet
                ? const Icon(Icons.check_rounded, color: AppColors.primary)
                : null,

            // todo: allow edit wallet, delete wallet here
            /*trailing: !services.developer.developerMode
                  ? null
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        if (pros.wallets.records.length > 1)
                          IconButton(
                            icon: Icon(Icons.delete_forever_rounded,
                                color: wallet == Current.wallet
                                    ? AppColors.primary
                                    : null),
                            onPressed: () async {
                              components.cubits.messageModal.update(
                                  title: 'DANGER!',
                                  content:
                                      'WARNING: You are about to delete a wallet. This action cannot be undone! Are you sure you want to delete it?',
                                  behaviors: <String, void Function()>{
                                    'CANCEL':
                                        components.cubits.messageModal.reset,
                                    'DELETE FOREVER': () async =>
                                        components.cubits.messageModal.update(
                                          title: 'CONFIRM DELETE',
                                          content:
                                              'To delete ${wallet.name} you will need to authenticate.',
                                          //child:
                                          behaviors: <String, void Function()>{
                                            'CANCEL': components
                                                .cubits.messageModal.reset,
                                            'OK': () async {
                                              print('not implemented yet');
                                              /*// todo convert to sail
                                              Navigator.pushNamed(
                                                  components
                                                      .routes.routeContext!,
                                                  '/security/security',
                                                  arguments: <String, Object>{
                                                    'buttonLabel':
                                                        'Delete ${wallet.name} Forever',
                                                    'onSuccess': () async {
                                                      Navigator.pop(components
                                                          .routes
                                                          .routeContext!);
                                                      if (wallet.id ==
                                                          Current.walletId) {
                                                        await switchWallet(pros
                                                            .wallets.records
                                                            .where((Wallet w) =>
                                                                w.id !=
                                                                wallet.id)
                                                            .first
                                                            .id);
                                                      }
                                                      await pros.wallets
                                                          .remove(wallet);
                                                      wallets =
                                                          pros.wallets.ordered;
                                                      initializeWalletSecurities();
                                                      setWalletsSecurities();
                                                    }
                                                  });*/
                                            }
                                          },
                                        )
                                  });
                            },
                          ),
                      ],
                    )*/
          ),
      ];

  void showWallets() {
    components.cubits.bottomModalSheet.show(
      children: walletOptions(onTap: components.cubits.bottomModalSheet.hide),
    );
    // we'd really like to trigger this whenever we lose focus of it...
    components.cubits.title.update(editable: false);
  }

  @override
  Widget build(BuildContext context) {
    //Animation<double> anima;
    //if (slowController.isCompleted) {
    //  anima = animate;
    //  controller.reset();
    //  controller.forward();
    //} else {
    //  anima = slowAnimation;
    //}
    final SearchCubit searchCubit = components.cubits.search;
    return BlocBuilder<TitleCubit, TitleCubitState>(
        builder: (context, state) => AnimatedBuilder(
            animation: slowAnimation,
            builder: (context, child) {
              return BlocBuilder<SearchCubit, SearchCubitState>(
                  builder: (BuildContext context, SearchCubitState _) {
                final title = cubit.title;
                return GestureDetector(
                    onTap: () async {
                      if (components.cubits.title.showWalletName &&
                          !searchCubit.state.show &&
                          title != 'Settings') {
                        showWallets();
                      }
                      //if (!dropDownActive) {
                      //  dropDownActive = true;
                      //  setWalletsSecurities();
                      //  await walletSelection();
                      //}
                    },
                    onDoubleTap: () async {
                      if (components.cubits.title.showWalletName &&
                          !searchCubit.state.show &&
                          title != 'Settings') {
                        bool next = false;
                        for (final Wallet wallet
                            in pros.wallets.ordered + pros.wallets.ordered) {
                          if (next) {
                            await switchWallet(wallet.id);
                            sail.to(components.cubits.location.state.path,
                                replaceOverride: true);
                            break;
                          }
                          if (Current.walletId == wallet.id) {
                            next = true;
                          }
                        }
                        setState(() {}); // recalculates the name of the wallet.
                        sail.menu(open: false);
                      }
                    },
                    child:
                        //FadeTransition(
                        //    opacity: anima,
                        //    child:
                        Container(
                            width: screen.width -
                                ((16 + 40 + 16) + //left lead
                                    (16 + 28 + 16) + // right connection
                                    (components.cubits.location.state.path ==
                                            '/wallet/holdings'
                                        ? (28 + 16)
                                        : 0) // search bar
                                ),
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  if (searchCubit.searchButtonShown &&
                                      searchCubit.shown)
                                    SearchTextField(cubit: searchCubit)
                                  else
                                    WalletNameText(
                                        title: cubit.title,
                                        editable: state.editable),
                                  BlocBuilder<FrontContainerCubit,
                                          FrontContainerCubitState>(
                                      builder: (context, state) {
                                    if (state.menuOpen && title != 'Settings') {
                                      return FadeIn(
                                          child: IconButton(
                                        onPressed: () => showWallets(),
                                        icon:
                                            //const Icon(
                                            //  Icons.expand_more_rounded,
                                            //  color: Colors.white,
                                            //)
                                            Container(
                                                height: 24,
                                                width: 24,
                                                child: SvgPicture.asset(
                                                    'assets/icons/custom/white/chevron-down.svg')),
                                      ));
                                    }
                                    return SizedBox.shrink();
                                  }),
                                ])));
              });
            }));
/*
    if (streams.app.loc.page.value == 'Splash') {
      slowController.forward(from: 0.0);
      return FadeTransition(
          opacity: slowAnimation, child: const Text('Welcome'));
    }
    if (loading || <String>['main', ''].contains(streams.app.loc.page.value)) {
      return const Text('');
    }
    FittedBox wrap(String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(x,
            style: Theme.of(context).textTheme.displayMedium!.copyWith(
                  color: AppColors.white,
                  fontWeight:
                      x.length >= 25 ? FontWeights.bold : FontWeights.semiBold,
                )));
    //.forward();
    FittedBox assetWrap(String x) => FittedBox(
        fit: BoxFit.fitWidth,
        child: GestureDetector(
            onTap: () async {
              //.reverse();
              await Future<void>.delayed(animationDuration);
              setState(() => fullname = !fullname);
            },
            child: FadeTransition(
                opacity: animation,
                child: Text(x,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: AppColors.white,
                          fontWeight: x.length >= 25
                              ? FontWeights.bold
                              : FontWeights.semiBold,
                        )))));
    if (<String>['Asset', 'Transactions'].contains(streams.app.loc.page.value)) {
      return assetWrap(fullname ? assetTitle : assetName(assetTitle));
    }
    fullname = false;
    return walletNumber() ??
        wrap((streams.reissue.form.value != null
                ? PageTitle.pageMapReissue[streams.app.loc.page.value]
                : null) ??
            PageTitle.pageMap[streams.app.loc.page.value] ??
            (streams.app.loc.page.value == 'Home'
                ? /*appContext.name.toTitleCase()*/ ' '
                : streams.app.loc.page.value));
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
    if (streams.app.loc.page.value != 'Home') {
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
                    .displayMedium!
                    .copyWith(color: AppColors.white)));
      } else if (appContext == AppContext.manage) {
        return Text(pros.wallets.currentWalletName,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.white));
      } else if (appContext == AppContext.swap) {
        return Text(pros.wallets.currentWalletName,
            style: Theme.of(context)
                .textTheme
                .displayMedium!
                .copyWith(color: AppColors.white));
      }
    }

    return null;
    */
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
                  .displayMedium!
                  .copyWith(color: AppColors.white)),
          //const Icon(Icons.expand_more_rounded, color: Colors.white),
          Container(
              height: 16,
              width: 16,
              child: SvgPicture.asset(
                  'assets/icons/custom/white/chevron-down.svg')),
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
                    await switchWallet(walletId);
                  },
                  leading: Container(
                      width: indicatorWidth,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.add, color: AppColors.primary)),
                  title: Text('New Wallet',
                      style: Theme.of(context).textTheme.bodyLarge),
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
                            streams.app.behavior.scrim.add(false);
                          },
                          child: Text(
                            'Show All',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
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
                    await switchWallet(walletId);
                  },
                  leading: Container(
                      width: indicatorWidth,
                      alignment: Alignment.centerLeft,
                      child: const Icon(Icons.add, color: AppColors.primary)),
                  title: Text('New Single Wallet',
                      style: Theme.of(context).textTheme.bodyLarge),
                )
            ] +
            <Widget>[
              for (Wallet wallet in getWallets())
                ListTile(
                    visualDensity: VisualDensity.compact,
                    onTap: () async {
                      Navigator.pop(components.routes.routeContext!);
                      if (wallet.id != Current.walletId) {
                        await switchWallet(wallet.id);
                      }
                    },
                    leading: walletsSecurities[wallet] == null ||
                            walletsSecurities[wallet]!.isEmpty ||
                            !services.developer.developerMode
                        ? Container(
                            //height: 16,
                            //width: 16,
                            child: SvgPicture.asset(
                                'assets/icons/custom/mobile/wallet.svg'))

                        //const Icon(
                        //  Icons.account_balance_wallet_rounded,
                        //  color: AppColors.primary,
                        //)
                        : SizedBox(
                            width: indicatorWidth,
                            child: Stack(children: holdingsIndicators(wallet))),
                    title: Text(wallet.name,
                        style: Theme.of(context).textTheme.bodyLarge),
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
                                            //: changeName,
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
                                                        '/login/verify',
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
                                                              await switchWallet(pros
                                                                  .wallets
                                                                  .records
                                                                  .where((Wallet
                                                                          w) =>
                                                                      w.id !=
                                                                      wallet.id)
                                                                  .first
                                                                  .id);
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

class WalletNameText extends StatelessWidget {
  final String title;
  final bool editable;
  const WalletNameText({Key? key, required this.title, required this.editable})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (!editable) {
      return Flexible(
          fit: FlexFit.loose,
          flex: 1,
          child: GestureDetector(
              onLongPress: () {
                if (components.cubits.title.showWalletName) {
                  components.cubits.title.update(editable: true);
                }
              },
              child: components.cubits.title.showWalletName
                  ? Text(title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style:
                          Theme.of(context).textTheme.displayMedium!.copyWith(
                                color: AppColors.white,
                                fontWeight: title.length >= 25
                                    ? FontWeights.bold
                                    : FontWeights.semiBold,
                              ))
                  : FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: Text(title,
                          maxLines: 1,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium!
                              .copyWith(
                                color: AppColors.white,
                                fontWeight: title.length >= 25
                                    ? FontWeights.bold
                                    : FontWeights.semiBold,
                              )))));
    }
    return WalletNameTextField(text: title);
  }
}

class WalletNameTextField extends StatefulWidget {
  final String text;
  const WalletNameTextField({Key? key, required this.text}) : super(key: key);

  @override
  WalletNameTextFieldState createState() => WalletNameTextFieldState();
}

class WalletNameTextFieldState extends State<WalletNameTextField> {
  final TextEditingController changeName = TextEditingController();
  final FocusNode focus = FocusNode();
  void initState() {
    super.initState();
    changeName.text = widget.text;
    focus.addListener(() {
      print(focus.hasFocus);
      if (!focus.hasFocus) {
        components.cubits.title.update(editable: false);
      }
    });
  }

  @override
  void dispose() {
    changeName.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    focus.requestFocus();
    return Container(
        width: screen.width -
            ((16 + 40 + 16) + //left lead
                (16 + 24 + 16) +
                (16 + 28 + 16) // right connection
            ),
        child: Overlay(initialEntries: [
          OverlayEntry(
              builder: (BuildContext context) => TextField(
                  controller: changeName,
                  focusNode: focus,
                  onSubmitted: (value) async {
                    if (changeName.text != '') {
                      if (Current.wallet is LeaderWallet) {
                        await pros.wallets.save(LeaderWallet.from(
                          Current.wallet as LeaderWallet,
                          name: changeName.text,
                          seed: await (Current.wallet as LeaderWallet).seed,
                        ));
                      } else if (Current.wallet is SingleWallet) {
                        await pros.wallets.save(SingleWallet.from(
                          Current.wallet as SingleWallet,
                          name: changeName.text,
                          //getWif: await wallet.getWif,
                        ));
                      }
                      //initializeWalletSecurities();
                      //setWalletsSecurities();
                      components.cubits.title.update(editable: false);
                    }
                  },
                  maxLines: 1,
                  style: Theme.of(context).textTheme.displayMedium!.copyWith(
                        color: AppColors.white,
                        fontWeight: widget.text.length >= 25
                            ? FontWeights.bold
                            : FontWeights.semiBold,
                      )))
        ]));
  }
}

class SearchTextField extends StatefulWidget {
  final SearchCubit cubit;
  const SearchTextField({Key? key, required this.cubit}) : super(key: key);

  @override
  SearchTextFieldState createState() => SearchTextFieldState();
}

class SearchTextFieldState extends State<SearchTextField> {
  final TextEditingController searchController = TextEditingController();
  final FocusNode focus = FocusNode();

  void initState() {
    super.initState();
    focus.addListener(() {
      print(focus.hasFocus);
      if (!focus.hasFocus) {
        widget.cubit.reset();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    focus.requestFocus();
    searchController.value = TextEditingValue(
        text: widget.cubit.state.text,
        selection: searchController.selection.baseOffset >
                widget.cubit.state.text.length
            ? TextSelection.collapsed(offset: widget.cubit.state.text.length)
            : searchController.selection);
    return Container(
        padding: EdgeInsets.only(top: 6),
        width: screen.width -
            ((16 + 40 + 16) + //left lead
                (16 + 24 + 16) +
                (16 + 28 + 16) // right connection
            ),
        child: Overlay(initialEntries: [
          OverlayEntry(
              builder: (BuildContext context) => TextField(
                    controller: searchController,
                    focusNode: focus,
                    maxLines: 1,
                    autocorrect: false,
                    textInputAction: TextInputAction.done,
                    cursorColor: AppColors.white87,
                    showCursor: true,
                    style: Theme.of(context).textTheme.displayMedium!.copyWith(
                          color: AppColors.white,
                          fontWeight: searchController.text.length >= 25
                              ? FontWeights.bold
                              : FontWeights.semiBold,
                        ),
                    decoration: InputDecoration(
                      border:
                          InputBorder.none, // Set border to InputBorder.none
                    ),
                    onChanged: (value) =>
                        widget.cubit.update(text: value.toUpperCase()),
                    onSubmitted: (value) async => widget.cubit
                        .update(text: value.toUpperCase(), show: false),
                    onEditingComplete: () => widget.cubit.update(show: false),
                    onTapOutside: (_) async {
                      FocusScope.of(context).unfocus();
                      // must wait in case they click the x button
                      await Future.delayed(fadeDuration)
                          .then((value) => widget.cubit.update(show: false));
                    },
                  ))
        ]));
  }
}
