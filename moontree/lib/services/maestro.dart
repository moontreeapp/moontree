/// TODO: fix and implement maestro

// // ignore_for_file: unnecessary_cast
// 
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:moontree/cubits/utilities.dart';
// import 'package:moontree/domain/concepts/sections.dart';
// import 'package:moontree/domain/concepts/side.dart';
// import 'package:moontree/cubits/cubit.dart' show cubits;
// //import 'package:moontree/presentation/services/services.dart' show back;
// /* snap back method not great 
// class Snapshot {
//   Map<UpdateMixin, EquatableMixin> snapshot = {};
//   Snapshot(this.snapshot);
//   void execute() {
//     for (var cubit in snapshot.keys) {
//       cubit.setState(snapshot[cubit]);
//     }
//   }
// }
// */
// 
// class Maestro {
//   /* snap back method not great 
//   List<Snapshot> snapshots = [];
//   */
//   //List<Function> backStack = [];
//   List<NavbarSection> sectionsHistory = [];
// 
//   Maestro();
// 
//   List<UpdateSectionMixin> get _sectionCubits => [
//         cubits.walletLayer,
//       ];
// 
//   /*
//   List<UpdateMixin> get _navbarCubits => [
//         cubits.navbar,
//         cubits.emojiCarousel,
//         cubits.starSelector,
//         cubits.gallery,
//       ];
//   */
// 
//   bool get _allSectionCubitsAreHidden =>
//       _sectionCubits.every((cubit) => !(cubit as Cubit).state.active);
// 
//   /// when we do an action we can register a back function
//   //void registerBack(Function function) => backStack.add(function);
// 
//   /* snap back method not great 
//   /// takes a snapshot of the current state of the app
//   Snapshot snapCubits(List<UpdateMixin> cubes) =>
//       Snapshot({for (var cube in cubes) cube: (cube as Cubit).state});
// 
//   void snapBack() {
//     final snapshot = snapshots.removeLast();
//     snapshot.execute();
//     //cubits.navbar.mid();
//     //cubits.profile.update(active: false);
//   }
// */
// 
// 
// 
// 
//   void sectionBack({Function? beforeBack, Function? afterBack}) {
//     //cubits.navbar.mid();
//     //cubits.profile.update(active: false);
//     beforeBack?.call();
//     if (sectionsHistory.length > 1) {
//       sectionsHistory.removeLast(); // remove current section
//       conduct(sectionsHistory.last, remember: false);
//     } else {
//       conduct(NavbarSection.wallet, remember: true);
//     }
//     afterBack?.call();
//   }
// 
//   void conduct(NavbarSection section, {bool remember = true}) {
//     /* snap back method not great 
//     snapshots .add(snapCubits(_navbarCubits + (_sectionCubits as List<UpdateMixin>)));*/
//     if (remember) {
//       sectionsHistory.add(section);
//     }
//     switch (section) {
//       case NavbarSection.wallet:
//         _activeateHome();
//         cubits.exploreLayer.update(active: false, side: Side.right);
//         cubits.createLayer.update(active: false, side: Side.right);
//         cubits.crewLayer.update(active: false, side: Side.right);
//         cubits.profile.update(active: false);
//         coda([
//           cubits.exploreLayer,
//           cubits.createLayer,
//           cubits.crewLayer,
//           cubits.profile,
//         ]);
//         break;
//       case NavbarSection.send:
//         _activeateExplore();
//         cubits.homeLayer.update(active: false);
//         cubits.createLayer.update(active: false, side: Side.right);
//         cubits.crewLayer.update(active: false, side: Side.right);
//         cubits.profile.update(active: false);
//         coda([
//           cubits.createLayer,
//           cubits.homeLayer,
//           cubits.crewLayer,
//           cubits.profile,
//         ]);
//         break;
//       case NavbarSection.recieve:
//         _activeateCreate();
//         cubits.homeLayer.update(active: false);
//         cubits.exploreLayer.update(active: false, side: Side.left);
//         cubits.crewLayer.update(active: false, side: Side.right);
//         cubits.profile.update(active: false);
//         coda([
//           cubits.homeLayer,
//           cubits.exploreLayer,
//           cubits.crewLayer,
//           cubits.profile,
//         ]);
//         break;
//       case NavbarSection.manage:
//         _activeateCrew();
//         cubits.homeLayer.update(active: false);
//         cubits.exploreLayer.update(active: false, side: Side.left);
//         cubits.createLayer.update(active: false, side: Side.left);
//         cubits.profile.update(active: false);
//         coda([
//           cubits.homeLayer,
//           cubits.exploreLayer,
//           cubits.createLayer,
//           cubits.profile,
//         ]);
//         break;
// 
//       case NavbarSection.none:
//         break;
//     }
//   }
// 
//   void coda(List<SectionMixin> sectionCubits) {
//     /// REMOVING TRANSITIONS
//     //Future.delayed(slideDuration, () {
//     //  for (var cubit in sectionCubits) {
//     //    cubit.hide();
//     //  }
//     //  if (_allSectionCubitsAreHidden) {
//     //    _activeateHome();
//     //  }
//     //});
//     for (var cubit in sectionCubits) {
//       cubit.hide();
//     }
//     if (_allSectionCubitsAreHidden) {
//       _activeateHome();
//     }
//   }
// 
//   void _activeateHome() {
//     //cubits.navbar.nav(section: NavbarSection.wallet);
//     cubits.navbar.navOnly(section: NavbarSection.wallet);
//     cubits.homeLayer.update(active: true);
//   }
// 
//   void _activeateExplore() {
//     cubits.navbar.navOnly(section: NavbarSection.send);
//     cubits.exploreLayer.update(
//         active: true,
//         side: cubits.homeLayer.state.active ? Side.right : Side.left);
//   }
// 
//   void _activeateCreate() {
//     cubits.navbar.navOnly(section: NavbarSection.recieve);
//     //cubits.navbar.nav(section: NavbarSection.recieve);
//     cubits.createLayer.update(
//         active: true,
//         side: cubits.homeLayer.state.active || cubits.exploreLayer.state.active
//             ? Side.right
//             : Side.left);
//     cubits.cameraView.update(isSubmitting: false);
//   }
// 
//   void _activeateCrew() {
//     cubits.navbar.navOnly(section: NavbarSection.manage);
//     cubits.crewLayer.update(
//         active: true,
//         side: cubits.homeLayer.state.active ||
//                 cubits.exploreLayer.state.active ||
//                 cubits.createLayer.state.active
//             ? Side.right
//             : Side.left);
//   }
// }
// 