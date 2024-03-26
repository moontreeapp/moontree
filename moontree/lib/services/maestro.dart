import 'package:moontree/cubits/utilities.dart';
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
        await awaitFor(
          cubits.pane.unattached,
          duration: slideDuration,
          wait: const Duration(milliseconds: 40),
        );
      }
    }
  }

  Future<void> _activeateHome() async {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.wallet);
    await inactiveateAllBut(cubits.wallet.state);
    cubits.wallet.update(active: true);
    await Future.delayed(slideDuration);
    cubits.ignore.update(active: false);
  }

  void _activeateMint() {
    cubits.ignore.update(active: true);
    cubits.navbar.update(section: NavbarSection.mint);
    cubits.wallet.update(active: false);
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
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
    );
    cubits.wallet.update(active: false);
    await Future.delayed(slideDuration * 2);
    cubits.transactions.update(active: true);
    //cubits.pane.update(
    //    scrollableChild: (ScrollController scroller) =>
    //        TransactionsPage(scroller:scroller));
    cubits.ignore.update(active: false);
  }
}
