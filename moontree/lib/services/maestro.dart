import 'package:moontree/cubits/appbar/cubit.dart';
import 'package:moontree/cubits/fade/cubit.dart';
import 'package:moontree/cubits/mixins.dart';
import 'package:moontree/domain/concepts/sections.dart';
//import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/cubits/cubit.dart' show cubits;
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';

class Maestro {
  List<NavbarSection> sectionsHistory = [];

  Maestro();

  //List<UpdateSectionMixin> get _sectionCubits => [
  //      cubits.wallet,
  //    ];

  bool get _allSectionCubitsAreHidden =>
      cubits.navbar.state.section == NavbarSection.none;
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
    for (dynamic c in [cubits.wallet, cubits.transactions]) {
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

  Future<void> _activeateHome() async {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.wallet);
    cubits.appbar.update(leading: AppbarLeading.connection, title: 'Wallet 1');
    cubits.holding.update(active: false);
    await inactiveateAllBut(cubits.wallet.state);
    cubits.wallet.update(active: true);
    if (cubits.pane.height != screen.pane.maxHeight) {
      cubits.pane.update(height: screen.pane.maxHeight - 1);
      cubits.pane.update(height: screen.pane.maxHeight);
    }
    cubits.pane.update(min: screen.pane.minHeightPercent);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    await Future.delayed(slideDuration);
    cubits.ignore.update(active: false);
  }

  Future<void> _activeateMint() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.navbar.update(section: NavbarSection.mint);
    await inactiveateAllBut(null);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }

  void _activeateSwap() {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.swap);
    cubits.wallet.update(active: false);
    cubits.ignore.update(active: false);
  }

  Future<void> activateTransactions() async {
    cubits.ignore.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeOut);
    cubits.appbar.update(leading: AppbarLeading.back, title: 'Coin');
    cubits.menu.update(active: false);
    cubits.holding.update(active: true);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
      min: screen.pane.midHeightPercent,
    );
    await inactiveateAllBut(cubits.transactions.state);
    cubits.transactions.update(active: true);
    cubits.fade.update(fade: FadeEvent.fadeIn);
    cubits.ignore.update(active: false);
  }
}
