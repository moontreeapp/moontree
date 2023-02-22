// import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pages/splash.dart';
import 'package:flutter/material.dart';

import 'package:client_front/application/utilities.dart';
import 'package:client_front/application/navbar/height/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/services/services.dart' show beamer;

enum Section { login, wallet, manage, swap, settings }

class Manifest {
  final Section? section;
  final Widget? backChild;
  final PageContainerHeight frontHeight;
  final NavbarHeight navbarHeight;
  final String? frontPath;
  final Widget? extraChild;
  final bool extraHideFront;
  const Manifest(
      {this.section,
      this.backChild,
      this.frontHeight = PageContainerHeight.same,
      this.navbarHeight = NavbarHeight.same,
      this.frontPath,
      this.extraChild,
      this.extraHideFront = false});
}

class Sailor {
  static const String initialPath = '/login/create';
  static const Map<Section, String> initialPaths = {
    Section.login: initialPath,
    Section.wallet: '/wallet/holdings',
    Section.manage: '/manage',
    Section.swap: '/swap',
    Section.settings: '/menu',
  };
  static const Map<String, Manifest> destinationMap = {
    //'/splash': Manifest(
    //  section: Section.login,
    //  frontHeight: PageContainerHeight.max,
    //  navbarHeight: NavbarHeight.hidden,
    //  frontPath: '/splash',
    //  extraChild: Splash(),
    //  extraHideFront: true,
    //),
    '/login/create': Manifest(
      section: Section.login,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create',
    ),
    '/login/create/native': Manifest(
      section: Section.login,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create/native',
    ),
    '/login/create/password': Manifest(
      section: Section.login,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create/password',
    ),
    '/login/native': Manifest(
      section: Section.login,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/native',
    ),
    '/login/password': Manifest(
      section: Section.login,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/password',
    ),
    '/wallet/holdings': Manifest(
      section: Section.wallet,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/wallet/holdings',
    ),
    '/wallet/holding': Manifest(
      section: Section.wallet,
      frontHeight: PageContainerHeight.mid,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/wallet/holding',
    ),
    '/wallet/holding/transaction': Manifest(
      section: Section.wallet,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/wallet/holding/transaction',
    ),
    '/manage': Manifest(
      section: Section.manage,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/manage',
    ),
    '/menu': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.min,
      navbarHeight: NavbarHeight.hidden,
      frontPath: null,
    ),
    '/menu/settings': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.min,
      navbarHeight: NavbarHeight.hidden,
      frontPath: null,
    ),
    '/settings/example': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/settings/example',
    ),
  };

  late List<Section> sectionHistory;
  late Map<Section, List<String>> destinationHistory;

  Sailor() {
    initializeHistory();
  }

  void initializeHistory() {
    sectionHistory = [Section.login];
    destinationHistory = {
      Section.login: [initialPath],
      Section.wallet: [],
      Section.manage: [],
      Section.swap: [],
      Section.settings: []
    };
  }

  Future<void> goBack() async {
    // Todo: key this off something else. like sailor current path or something
    if (['Holdings', 'Manage'].contains(components.cubits.title.state.title)) {
      await sailTo(location: '/menu');
    } else {
      // any page that uses ContentExtra layer for draggable sheets
      if (['Holding'].contains(components.cubits.title.state.title)) {
        // show front layer and instantly remove extra content before anything else.
        // todo make this dependant on the map.
        components.cubits.frontContainer.setHidden(false);
        components.cubits.extraContainer.reset();
      }
      sailBack();
    }
  }

  Future<void> sailTo({
    String? location,
    BuildContext? context,
    Section? section,
    Map<String, dynamic>? params,
    bool addToHistory = true,
    bool replaceOverride = false,
  }) async {
    if (location == null && section == null) {
      throw Exception('must supply location or section');
    }
    var addToDestinationHistory = true;
    if (location == null && destinationHistory[section]!.isNotEmpty) {
      location = destinationHistory[section]!.last;
      addToDestinationHistory = false;
    } else {
      location ??= initialPaths[section]!;
    }
    final manifest = destinationMap[location];
    if (manifest == null) {
      throw Exception('Invalid location: $location');
    }
    if (addToHistory) {
      print('adding to history');
      _handleHistoryAddition(
        location,
        currSection: sectionHistory.last,
        destSection: manifest.section!,
        addToDestinationHistory: addToDestinationHistory,
      );
      print(destinationHistory);
    }
    updateCubits(location, manifest);

    // go there
    if (manifest.frontPath != null) {
      // todo: get rid of this pattern, just pass args in if you want.
      final matchParam = manifest.frontPath!.split(':').last;
      final ending = params?[manifest.frontPath!.split(':').last] ?? '';
      final path = ending == ''
          ? manifest.frontPath!
          : manifest.frontPath!.replaceFirst(matchParam, ending);
      _navigate(path, replace: replaceOverride, context: context);
    }
  }

  void sailBack() {
    //sailTo(
    //  location: _handleHistoryRemoval(),
    //  beam: true,
    //  addToHistory: false,
    //);
    String location = _handleHistoryRemoval();
    final manifest = destinationMap[location]!;
    updateCubits(location, manifest);
    //Navigator.of(components.routes.scaffoldContext!).pop();
    components.routes.navigatorKey.currentState!.pop();
  }

  void updateCubits(String location, Manifest manifest) {
    // update app bar stuff
    components.cubits.title.update(path: location);

    // update nav bar stuff
    //components.cubits.navbarHeight.setHeightTo(height: manifest.navbarHeight);

    // update back stuff
    components.cubits.backContainer.update(child: manifest.backChild);

    // update front height,
    components.cubits.frontContainer.setHeightTo(height: manifest.frontHeight);

    // fade out front

    // set the content on the extra layer
    components.cubits.extraContainer.set(child: manifest.extraChild);
  }

  /// mutates history state
  _handleHistoryAddition(
    location, {
    required Section currSection,
    required Section destSection,
    bool addToDestinationHistory = true,
  }) {
    if (currSection != destSection) {
      sectionHistory.add(destSection);
    }
    if (addToDestinationHistory) {
      destinationHistory[destSection]!.add(location);
    }
  }

  /// mutates history state, returns previous destination
  String _handleHistoryRemoval([bool removed = false]) {
    if (sectionHistory.isEmpty) {
      initializeHistory();
      return initialPath;
    }
    if (destinationHistory[sectionHistory.last]!.isNotEmpty) {
      if (!removed) {
        destinationHistory[sectionHistory.last]!.removeLast();
      } else {
        return destinationHistory[sectionHistory.last]!.last;
      }
      if (destinationHistory[sectionHistory.last]!.isNotEmpty) {
        return destinationHistory[sectionHistory.last]!.last;
      }
    }
    sectionHistory.removeLast();
    return _handleHistoryRemoval(true);
  }

  void _navigate(String path, {bool replace = false, BuildContext? context}) =>
      replace
          ? context == null
              ? components.routes.navigatorKey.currentState!
                  .pushReplacementNamed(path)
              : Navigator.of(context).pushReplacementNamed(path)
          : context == null
              ? components.routes.navigatorKey.currentState!.pushNamed(path)
              : Navigator.of(context).pushNamed(path);
  //? Navigator.of(context ?? components.routes.routeContext!)
  //    .pushReplacementNamed(path)
  //: Navigator.of(context ?? components.routes.routeContext!)
  //    .pushNamed(path);
  // !.push(MaterialPageRoute(builder: (context) => MyPage()),);
}
