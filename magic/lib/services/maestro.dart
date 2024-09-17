import 'package:magic/cubits/appbar/cubit.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:magic/domain/concepts/sections.dart';
import 'package:magic/cubits/cubit.dart' show cubits;
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/assets/names.dart';
import 'package:magic/services/services.dart';

class Maestro {
  List<NavbarSection> sectionsHistory = [];
  bool locked = false;

  Maestro();

  //List<UpdateSectionMixin> get _sectionCubits => [
  //      cubits.wallet,
  //    ];

  //bool get _allSectionCubitsAreHidden =>
  //    cubits.navbar.state.section == NavbarSection.none;
  //_sectionCubits.every((cubit) => !(cubit as Cubit).state.active);

  void lockedRun({Function? fn, Duration? duration}) {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    fn?.call();
    if (duration != null) {
      Future.delayed(duration, () => locked = false);
    } else {
      locked = false;
    }
  }

  void sectionBack({Function? beforeBack, Function? afterBack}) {
    //cubits.navbar.mid();
    //cubits.mint.update(active: false);
    beforeBack?.call();
    if (sectionsHistory.length > 1) {
      sectionsHistory.removeLast(); // remove current section
      conduct(sectionsHistory.last, remember: false);
    } else {
      conduct(NavbarSection.wallet, remember: true);
    }
    afterBack?.call();
  }

  void conduct(NavbarSection section, {bool remember = true}) {
    /* snap back method not great
     snapshots .add(snapCubits(_navbarCubits + (_sectionCubits as List<UpdateMixin>)));*/
    if (remember) {
      sectionsHistory.add(section);
    }
    switch (section) {
      case NavbarSection.wallet:
        activateHome();
        break;
      case NavbarSection.mint:
        activateMint();
        break;
      case NavbarSection.swap:
        activateSwap();
        break;
      case NavbarSection.none:
        break;
    }
  }

  Future<void> awaitFor(
    bool Function() fn, {
    Duration? wait,
    Duration? duration,
    Duration? timeout,
  }) async {
    if (duration != null) {
      await Future.delayed(duration);
    }
    final timeoutTime = timeout != null ? DateTime.now().add(timeout) : null;
    while (!fn()) {
      if (timeoutTime != null && DateTime.now().isAfter(timeoutTime)) {
        break;
      }
      await Future.delayed(wait ?? const Duration(milliseconds: 100));
    }
  }

  Future<void> inactivateAllBut(String? except) async {
    for (UpdatableCubit c in cubits.paneCubits) {
      if (c.key != except && c.state.active) {
        c.deactivate();
        cubits.fade.update(fade: FadeEvent.fadeOut);
        await awaitFor(
          cubits.pane.unattached,
          duration: fadeDuration,
          wait: const Duration(milliseconds: 40),
        );
      }
    }
  }

  void toggleFull() {
    try {
      cubits.pane.state.scroller?.jumpTo(0);
    } catch (_) {}
    if (cubits.pane.height <= screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.maxHeight);
      cubits.navbar.activate();
    } else {
      cubits.pane.snapTo(screen.pane.minHeight);
      cubits.navbar.deactivate();
    }
  }

  bool activateMenu() {
    if (cubits.menu.state.sub != SubMenu.none) {
      deactivateSubMenu();
    }
    return toggleMidMin();
  }

  // returns true if it's toggled to mid height, false at min
  bool toggleMidMin() {
    try {
      cubits.pane.state.scroller?.jumpTo(0);
    } catch (_) {}
    if (cubits.pane.height > screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.midHeight, force: true);
      //cubits.navbar.update(hidden: false);
      return true;
    } else if (cubits.pane.height < screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.midHeight, force: true);
      //cubits.navbar.update(hidden: false);
      return true;
    } else if (cubits.pane.height == screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.minHeight, force: true);
      //cubits.navbar.update(hidden: true);
      return false;
    }
    // this should never happen but if it does reset. might fix glitch.
    cubits.pane.snapTo(screen.pane.midHeight, force: true);
    return true;
  }

  void hideSubMenuOnDrag(double height) {
    if (height > (screen.pane.midHeight + screen.pane.minHeight) / 2) {
      if (cubits.menu.state.sub != SubMenu.none) {
        deactivateSubMenu();
      }
    }
  }

  void hideNavbarOnDrag(double height) {
    if (height < (screen.pane.midHeight + screen.pane.minHeight) / 2) {
      if (cubits.navbar.isActive) {
        cubits.navbar.deactivate();
      }
    } else {
      if (!cubits.navbar.isActive) {
        cubits.navbar.activate();
      }
    }
  }

  void setMinToMiddleOnMax(double height) {
    if (height == screen.pane.maxHeight) {
      cubits.pane.update(min: screen.pane.midHeightPercent);
    } else if (height <= screen.pane.midHeight + 1 &&
        cubits.pane.state.min == screen.pane.midHeightPercent) {
      cubits.pane.update(min: screen.pane.minHeightPercent);
    }
  }

  /// this doesn't work as exected because as soon as we reach the middle it
  /// sets it to max and continues to drag up to max, if it were to stop there
  /// then the scroll list action would take over and we start scrolling the
  /// list instead which is not what we want.
  //void setMaxToMiddleOnMin(double height) {
  //  see('height: $height, screen.pane.minHeight: ${screen.pane.minHeight}');
  //  if (height < screen.pane.minHeight + 1) {
  //    see('setting to mid');
  //    cubits.pane.update(max: screen.pane.midHeightPercent);
  //  } else if (height == screen.pane.midHeight) {
  //    see('setting to max');
  //    cubits.pane.update(max: screen.pane.maxHeightPercent);
  //  }
  //}

  //void snapOnDrag(double height) {
  //  if (height < (screen.pane.midHeight - screen.pane.minHeight) / 2) {
  //    cubits.pane.update(height: screen.pane.minHeight);
  //  } else if (height < (screen.pane.maxHeight - screen.pane.midHeight) / 2) {
  //    cubits.pane.update(height: screen.pane.midHeight);
  //  } else if (height >= (screen.pane.maxHeight - screen.pane.midHeight) / 2) {
  //    cubits.pane.update(height: screen.pane.maxHeight);
  //  }
  //}

  //Future<void> activate(Function func) async {
  //  if (locked) {
  //    return;
  //  } else {
  //    locked = true;
  //  }
  //  await func();
  //  locked = false;
  //}

  Future<void> activateHome() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.wallet.populateAssets(30);
    cubits.app.animating = true;
    // if pane is not in middle move it to middle first
    if (cubits.pane.height != screen.pane.midHeight) {
      toggleMidMin();
      await Future.delayed(slideDuration);
    }
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.wallet, active: true);
    cubits.appbar.update(
      leading: AppbarLeading.menu,
      title: 'Magic',
      clearTitleChild: true,
      onLead: activateMenu,
      onTitle: activateMenu,
    );
    cubits.holding.deactivate();
    cubits.transactions.clearTransactions();
    cubits.balance.update(active: true);
    cubits.menu.update(active: true);
    await inactivateAllBut(cubits.wallet.key);
    cubits.wallet.update(active: true);
    cubits.pane.heightBehavior = (double h) {
      hideNavbarOnDrag(h);
      hideSubMenuOnDrag(h);
      setMinToMiddleOnMax(h);
      //setMaxToMiddleOnMin(h);
    };
    cubits.pane.update(
      max: cubits.wallet.state.holdings.length > 5
          ? screen.pane.maxHeightPercent
          : screen.pane.midHeightPercent,
      min: screen.pane.minHeightPercent,
    );
    if (cubits.pane.height != screen.pane.midHeight) {
      if (cubits.pane.state.height == screen.pane.midHeight) {
        cubits.pane.update(height: screen.pane.midHeight - 1);
      }
      cubits.pane.update(height: screen.pane.midHeight);
    }
    cubits.fade.update(fade: FadeEvent.fadeIn);
    await Future.delayed(slideDuration);
    cubits.holding.clear();
    cubits.ignore.update(active: false);
    cubits.app.animating = false;
    locked = false;
  }

  Future<void> activateMint() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(section: NavbarSection.mint, active: true);
    await inactivateAllBut(null);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    locked = false;
  }

  void activateSwap() {
    if (locked) {
      return;
    } else {
      locked = true;
    }

    /// place for testing stuff since mint is unused:
    ///
    //see(makeMnemonic());
    //see(cubits.keys.master.derivationWallets.first.mnemonic);
    //see(cubits.keys.state.mnemonics);
    //cubits.keys.reset();
    //see(cubits.keys.dump());
    //see(cubits.keys.load());
    //see("storage.read(key: 'key') ${await storage.read(key: 'key')}");
    //cubits.keys.update(mnemonics: [makePubKey()]);
    //cubits.keys.dump();
    //DerivationWallet wallet = DerivationWallet(mnemonic: makeMnemonic());
    //see('mnemonic: ${wallet.mnemonic}');
    //see('entropy: ${wallet.entropy}');
    //see('seed: ${wallet.seed}');
    //see("storage.read(key: 'key') ${await storage.read(key: 'key')}");
    //cubits.toast.flash(
    //    msg: const ToastMessage(
    //  title: 'test toast',
    //  text: 'animate correctly',
    //));
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.swap, active: true);
    cubits.wallet.update(active: false);
    cubits.ignore.update(active: false);
    locked = false;
  }

  Future<void> activateHistory({
    Holding? holding,
    bool redirectOnEmpty = false,
  }) async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.transactions.populateAllTransactions(holding: holding);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: '',
      titleChild: const ResponsiveHighlightedNameView(),
      onLead: activateHome,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.balance.update(active: false);
    cubits.holding.update(
      active: true,
      section: HoldingSection.none,
      holding: holding,
    );
    if (cubits.pane.height != screen.pane.midHeight) {
      if (cubits.pane.state.height == screen.pane.midHeight) {
        cubits.pane.update(height: screen.pane.midHeight - 1);
      }
      cubits.pane.update(height: screen.pane.midHeight);
      await Future.delayed(slideDuration);
    }
    cubits.pane.update(
      active: true,
      //height: screen.pane.midHeight,
      //max: screen.pane.maxHeightPercent,
      max: cubits.transactions.state.transactions.length > 6
          ? screen.pane.maxHeightPercent
          : screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    cubits.pane.heightBehavior = null;
    await inactivateAllBut(cubits.transactions.key);
    cubits.transactions.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    cubits.pane.setOnBottomReached(
        () => cubits.transactions.populateTransactions(holding: holding));
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
    //if (redirectOnEmpty && cubits.holding.state.holding.sats.value == 0) {
    //  activateReceive(cubits.holding.state.holding.blockchain);
    //}

    //if (redirectOnEmpty &&
    //    ['\$ -', '\$ 0.00'].contains(cubits.holding.state.usd) &&
    //    (cubits.transactions.state.transactions.length +
    //            cubits.transactions.state.mempool.length ==
    //        0)) {
    //  if (locked) {
    //    return;
    //  } else {
    //    locked = true;
    //  }
    //  await Future.delayed(slideDuration);
    //  locked = false;
    //  activateReceive(cubits.holding.state.holding.blockchain);
    //}
  }

  /// when on a transactions list screen you clickon a coin at the top
  Future<void> activateOtherHolding(Holding holding) async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    await Future.delayed(fadeDuration, () {
      cubits.holding.update(holding: holding);
      cubits.transactions.clearTransactions();
      cubits.transactions.populateTransactions(holding: holding);
      cubits.transactions.populateMempoolTransactions(holding: holding);
    });
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: '',
      titleChild: const ResponsiveHighlightedNameView(),
      onLead: activateHome,
      onTitle: cubits.appbar.none,
    );
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> activateSend() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: 'Send',
      clearTitleChild: true,
      onLead: () {
        cubits.send.reset();
        activateHistory();
      },
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(active: true, section: HoldingSection.send);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactivateAllBut(cubits.send.key);
    cubits.send.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> activateReceive(Blockchain blockchain) async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.receive.populateReceiveAddress(blockchain);
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: 'Receive',
      clearTitleChild: true,
      onLead: activateHistory,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(active: true, section: HoldingSection.receive);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactivateAllBut(cubits.receive.key);
    cubits.receive.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> activateTransaction(TransactionDisplay transaction) async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: 'Transaction',
      clearTitleChild: true,
      onLead: activateHistory,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(
        active: true,
        section: HoldingSection.transaction,
        transaction: transaction);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactivateAllBut(cubits.transaction.key);
    cubits.transaction.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> activateSwapOnHolding() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Swap',
      clearTitleChild: true,
      onLead: activateHistory,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(active: true, section: HoldingSection.swap);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactivateAllBut(cubits.swap.key);
    cubits.swap.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> activateManageOnHolding() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.pane.setOnBottomReached(null);
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Manage',
      clearTitleChild: true,
      onLead: activateHistory,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(active: true, section: HoldingSection.swap);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactivateAllBut(cubits.manage.key);
    cubits.manage.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }

  Future<void> deactivateSubMenu() async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.navbar.update(active: false);
    cubits.menu.update(active: true, sub: SubMenu.none);
    cubits.balance.update(active: true);
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    cubits.appbar.update(
      leading: AppbarLeading.menu,
      title: 'Magic',
      clearTitleChild: true,
      onLead: activateMenu,
      onTitle: activateMenu,
    );
    locked = false;
  }

  Future<void> activateSubMenu(SubMenu sub) async {
    if (locked) {
      return;
    } else {
      locked = true;
    }
    cubits.app.animating = true;
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: '',
      //clearTitleChild: true,
      onLead: deactivateSubMenu,
      onTitle: deactivateSubMenu,
    );
    cubits.menu.update(active: true, sub: sub);
    cubits.balance.hide();
    await Future.delayed(slideDuration, () => cubits.app.animating = false);
    locked = false;
  }
}
