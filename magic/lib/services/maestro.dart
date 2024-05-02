import 'package:magic/cubits/appbar/cubit.dart';
import 'package:magic/cubits/canvas/holding/cubit.dart';
import 'package:magic/cubits/canvas/menu/cubit.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/cubits/mixins.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/domain/concepts/holding.dart';
import 'package:magic/domain/concepts/sections.dart';
import 'package:magic/cubits/cubit.dart' show cubits;
import 'package:magic/domain/concepts/transaction.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';
import 'package:magic/services/wallet/hd.dart';

class Maestro {
  List<NavbarSection> sectionsHistory = [];

  Maestro();

  //List<UpdateSectionMixin> get _sectionCubits => [
  //      cubits.wallet,
  //    ];

  //bool get _allSectionCubitsAreHidden =>
  //    cubits.navbar.state.section == NavbarSection.none;
  //_sectionCubits.every((cubit) => !(cubit as Cubit).state.active);

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
        _activeateHome();
        break;
      case NavbarSection.mint:
        _activeateMint();
        break;
      case NavbarSection.swap:
        _activeateSwap();
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

  Future<void> inactiveateAllBut(String? except) async {
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
  //  print('height: $height, screen.pane.minHeight: ${screen.pane.minHeight}');
  //  if (height < screen.pane.minHeight + 1) {
  //    print('setting to mid');
  //    cubits.pane.update(max: screen.pane.midHeightPercent);
  //  } else if (height == screen.pane.midHeight) {
  //    print('setting to max');
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

  Future<void> _activeateHome() async {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.wallet, active: true);
    cubits.appbar.update(
      leading: AppbarLeading.menu,
      title: 'Magic',
      onLead: activateMenu,
      onTitle: activateMenu,
    );
    cubits.holding.update(active: false);
    cubits.balance.update(active: true);
    cubits.menu.update(active: true);
    await inactiveateAllBut(cubits.wallet.key);
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
    cubits.ignore.update(active: false);
  }

  Future<void> _activeateMint() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(section: NavbarSection.mint, active: true);
    await inactiveateAllBut(null);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);

    /// place for testing stuff since mint is unused:
    print("storage.read(key: 'key') ${await storage.read(key: 'key')}");
    await storage.write(key: 'key', value: makePubKey());
    print("storage.read(key: 'key') ${await storage.read(key: 'key')}");
  }

  void _activeateSwap() {
    cubits.toast.flash(
        msg: const ToastMessage(
      title: 'test toast',
      text: 'animate correctly',
    ));
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.swap, active: true);
    cubits.wallet.update(active: false);
    cubits.ignore.update(active: false);
  }

  Future<void> activateHistory([Holding? holding]) async {
    cubits.transactions.populate();
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: 'Coin',
      onLead: _activeateHome,
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
    await inactiveateAllBut(cubits.transactions.key);
    cubits.transactions.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateSend() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Send',
      onLead: activateHistory,
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
    await inactiveateAllBut(cubits.send.key);
    cubits.send.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateReceive() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Receive',
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
    await inactiveateAllBut(cubits.receive.key);
    cubits.receive.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateTransaction(TransactionDisplay transaction) async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Transaction',
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
    await inactiveateAllBut(cubits.transaction.key);
    cubits.transaction.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateSwapOnHolding() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Swap',
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
    await inactiveateAllBut(cubits.swap.key);
    cubits.swap.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateManageOnHolding() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Manage',
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
    await inactiveateAllBut(cubits.manage.key);
    cubits.manage.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> deactivateSubMenu() async {
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.menu,
      title: 'Magic',
      onLead: activateMenu,
      onTitle: activateMenu,
    );
    cubits.menu.update(active: true, sub: SubMenu.none);
    cubits.balance.update(active: true);
  }

  Future<void> activateSubMenu(SubMenu sub) async {
    cubits.navbar.update(active: false);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: '',
      onLead: deactivateSubMenu,
      onTitle: deactivateSubMenu,
    );
    cubits.menu.update(active: true, sub: sub);
    cubits.balance.hide();
  }
}
