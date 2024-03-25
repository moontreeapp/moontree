import 'package:flutter/widgets.dart';
import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/sections.dart';
//import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/cubits/cubit.dart' show cubits;
import 'package:moontree/presentation/ui/wallet/transactions/feed/page.dart';
import 'package:moontree/presentation/utils/animation.dart';
import 'package:moontree/services/services.dart';

class Maestro {
  List<NavbarSection> sectionsHistory = [];

  Maestro();

  //List<UpdateSectionMixin> get _sectionCubits => [
  //      cubits.walletLayer,
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
        coda([
          //  cubits.sendLayer,
          //  cubits.receiveLayer,
          //  cubits.mint,
        ]);
        break;
      case NavbarSection.swap:
        _activeateSend();
        coda([
          cubits.walletLayer,
          //  cubits.sendLayer,
          //  cubits.receiveLayer,
          //  cubits.mint,
        ]);
        break;
      case NavbarSection.mint:
        _activeateMint();
        coda([
          cubits.walletLayer,
          //  cubits.sendLayer,
          //  cubits.receiveLayer,
          //  cubits.mint,
        ]);
        break;
      case NavbarSection.none:
        break;
    }
  }

  void coda(List<SectionMixin> sectionCubits) {
    /// REMOVING TRANSITIONS
    //Future.delayed(slideDuration, () {
    //  for (var cubit in sectionCubits) {
    //    cubit.hide();
    //  }
    //  if (_allSectionCubitsAreHidden) {
    //    _activeateHome();
    //  }
    //});
    for (var cubit in sectionCubits) {
      cubit.hide();
    }
    if (_allSectionCubitsAreHidden) {
      _activeateHome();
    }
  }

  Future<void> _activeateHome() async {
    cubits.transactionsLayer.update(active: false);
    cubits.pane.removeChildren();
    cubits.navbar.update(section: NavbarSection.wallet);
    final prevHeight = cubits.pane.state.height;
    if (prevHeight != screen.pane.maxHeight) {
      print('waiting');
      cubits.pane.update(active: true, height: screen.pane.maxHeight);
      await Future.delayed(slideDuration);
    }
    cubits.walletLayer.update(active: true);
    //cubits.sendLayer.update(active: false);
    //cubits.receiveLayer.update(active: false);
    //cubits.mint.update(active: false);
  }

  void _activeateSend() {
    cubits.navbar.update(section: NavbarSection.swap);
    cubits.walletLayer.update(active: false);
    //cubits.sendLayer.update(active: false);
    //cubits.receiveLayer.update(active: false);
    //cubits.mint.update(active: false);
  }

  void _activeateMint() {
    cubits.navbar.update(section: NavbarSection.mint);
    cubits.walletLayer.update(active: false);
    //cubits.receiveLayer.update(active: false);
    //cubits.sendLayer.update(active: false);
    //cubits.mint.update(active: false);
  }

  Future<void> activateTransactions() async {
    cubits.walletLayer.update(active: false);
    await Future.delayed(fadeDuration);
    cubits.pane.update(
      active: true,
      height: screen.pane.midHeight,
    );
    await Future.delayed(slideDuration);
    cubits.transactionsLayer.update(active: true);
    cubits.pane.update(
        scrollableChild: (ScrollController scroller) =>
            TransactionsFeedPage(scroller: scroller));
  }
}
