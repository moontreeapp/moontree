import 'package:magic/cubits/appbar/cubit.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/domain/concepts/sections.dart';
//import 'package:magic/domain/concepts/side.dart';
import 'package:magic/cubits/cubit.dart' show cubits;
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/services/services.dart';

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

  Future<void> inactiveateAllBut(dynamic except) async {
    for (dynamic c in [cubits.wallet, cubits.transactions, cubits.send]) {
      if (c.state != except && c.state.active) {
        c.update(active: false);
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
      cubits.navbar.update(hidden: false);
    } else {
      cubits.pane.snapTo(screen.pane.minHeight);
      cubits.navbar.update(hidden: true);
    }
  }

  // returns true if it's toggled to mid height, false at min
  bool toggleMidMin() {
    try {
      cubits.pane.state.scroller?.jumpTo(0);
    } catch (_) {}
    if (cubits.pane.height > screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.midHeight);
      //cubits.navbar.update(hidden: false);
      return true;
    } else if (cubits.pane.height < screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.midHeight);
      //cubits.navbar.update(hidden: false);
      return true;
    } else if (cubits.pane.height == screen.pane.midHeight) {
      cubits.pane.snapTo(screen.pane.minHeight);
      //cubits.navbar.update(hidden: true);
      return false;
    }
    return true;
  }

  void hideNavbarOnDrag(double height) {
    if (height < (screen.pane.midHeight + screen.pane.minHeight) / 2) {
      if (!cubits.navbar.state.hidden) {
        cubits.navbar.update(hidden: true);
      }
    } else {
      if (cubits.navbar.state.hidden) {
        cubits.navbar.update(hidden: false);
      }
    }
  }

  void setMinToMiddleOnMax(double height) {
    if (height == screen.pane.maxHeight) {
      cubits.pane.update(min: screen.pane.midHeightPercent);
    } else if (height == screen.pane.midHeight) {
      cubits.pane.update(min: screen.pane.minHeightPercent);
    }
  }

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
    cubits.navbar.update(section: NavbarSection.wallet, hidden: false);
    cubits.appbar.update(
      leading: AppbarLeading.connection,
      title: 'Magic',
      onLead: toggleMidMin,
      onTitle: toggleMidMin,
    );
    cubits.holding.update(active: false);
    cubits.balance.update(active: true);
    cubits.menu.update(active: true);
    await inactiveateAllBut(cubits.wallet.state);
    cubits.wallet.update(active: true);
    cubits.pane.heightBehavior = (double h) {
      hideNavbarOnDrag(h);
      setMinToMiddleOnMax(h);
    };
    cubits.pane.update(
      max: cubits.wallet.state.assets.length > 5
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
    cubits.navbar.update(section: NavbarSection.mint, hidden: false);
    await inactiveateAllBut(null);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  void _activeateSwap() {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.swap, hidden: false);
    cubits.wallet.update(active: false);
    cubits.ignore.update(active: false);
  }

  Future<void> activateTransactions() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(hidden: true);
    cubits.appbar.update(
      leading: AppbarLeading.back,
      title: 'Coin',
      onLead: _activeateHome,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.balance.update(active: false);
    cubits.holding.update(active: true, send: false);
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
      max: screen.pane.maxHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    cubits.pane.heightBehavior = null;
    await inactiveateAllBut(cubits.transactions.state);
    cubits.transactions.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  Future<void> activateSend() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(hidden: true);
    cubits.appbar.update(
      leading: AppbarLeading.close,
      title: 'Send',
      onLead: activateTransactions,
      onTitle: cubits.appbar.none,
    );
    cubits.menu.update(active: false);
    cubits.holding.update(active: true, send: true);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      max: screen.pane.midHeightPercent,
      min: screen.pane.midHeightPercent,
    );
    await inactiveateAllBut(cubits.send.state);
    cubits.send.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }
}
