import 'package:moontree/cubits/utilities.dart';
import 'package:moontree/domain/concepts/sections.dart';
//import 'package:moontree/domain/concepts/side.dart';
import 'package:moontree/cubits/cubit.dart' show cubits;

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
      case NavbarSection.send:
        _activeateSend();
        coda([
          cubits.walletLayer,
          //  cubits.sendLayer,
          //  cubits.receiveLayer,
          //  cubits.mint,
        ]);
        break;
      case NavbarSection.receive:
        _activeateReceive();
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

  void _activeateHome() {
    cubits.navbar.update(section: NavbarSection.wallet);
    cubits.walletLayer.update(active: true);
    //cubits.sendLayer.update(active: false);
    //cubits.receiveLayer.update(active: false);
    //cubits.mint.update(active: false);
  }

  void _activeateSend() {
    cubits.navbar.update(section: NavbarSection.send);
    cubits.walletLayer.update(active: false);
    //cubits.sendLayer.update(active: false);
    //cubits.receiveLayer.update(active: false);
    //cubits.mint.update(active: false);
  }

  void _activeateReceive() {
    cubits.navbar.update(section: NavbarSection.receive);
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
}
