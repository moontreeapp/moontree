import 'package:flutter/material.dart';
//import 'package:client_back/streams/streams.dart'; // streams.app.path
import 'package:client_front/application/utilities.dart';
import 'package:client_front/application/navbar/cubit.dart';
import 'package:client_front/application/location/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class Manifest {
  final Section section;
  final String? title;
  final String? backPath;
  final FrontContainerHeight frontHeight;
  final NavbarHeight navbarHeight;
  final String? frontPath;
  final Widget? extraChild;
  final bool extraHideFront;
  const Manifest({
    required this.section,
    this.title,
    this.backPath,
    this.frontHeight = FrontContainerHeight.same,
    this.navbarHeight = NavbarHeight.same,
    this.frontPath,
    this.extraChild,
    this.extraHideFront = false,
  });
}

class Sail {
  static const String initialPath = '/login/create';
  static const Map<Section, String> initialPaths = {
    Section.login: initialPath,
    Section.wallet: '/wallet/holdings',
    Section.manage: '/manage',
    Section.swap: '/swap',
    Section.settings: '/menu',
  };

  static const Map<String, Manifest> destinationMap = {
    '/login/create': Manifest(
      title: 'Welcome',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create',
    ),
    '/login/create/native': Manifest(
      title: 'Native Security',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create/native',
    ),
    '/login/create/password': Manifest(
      title: 'Create Password Login',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create/password',
    ),
    '/login/create/resume': Manifest(
      title: 'Resume Password Setup',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/create/resume',
    ),
    '/login/native': Manifest(
      title: 'Locked',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/native',
    ),
    '/login/password': Manifest(
      title: 'Locked',
      section: Section.login,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/password',
    ),
    '/backup/intro': Manifest(
      title: 'Backup',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/intro',
    ),
    '/backup/seed': Manifest(
      title: 'Backup',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/seed',
    ),
    '/backup/keypair': Manifest(
      title: 'Backup',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/keypair',
    ),
    '/backup/verify': Manifest(
      title: 'Backup',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/verify',
    ),
    '/wallet/holdings': Manifest(
      title: 'Holdings', // should be wallet name
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/wallet/holdings',
      backPath: '/menu',
    ),
    '/wallet/holding': Manifest(
      title: 'Holding', // should be holding name
      section: Section.wallet,
      frontHeight: FrontContainerHeight.mid,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/wallet/holding',
    ),
    '/wallet/holding/transaction': Manifest(
      title: 'Transaction',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/wallet/holding/transaction',
    ),
    '/wallet/receive': Manifest(
      title: 'Receive',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/wallet/receive',
    ),
    '/manage': Manifest(
      title: 'Manage',
      section: Section.manage,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/manage',
      backPath: '/menu',
    ),
    '/swap': Manifest(
      title: 'Swap',
      section: Section.swap,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/swap',
      backPath: '/menu',
    ),
    '/restore/import': Manifest(
      title: 'Import',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/restore/import',
    ),
    '/support/about': Manifest(
      title: 'About',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/support/about',
    ),
    '/support/support': Manifest(
      title: 'Support',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/support/support',
    ),
  };

  final List<Section> sectionHistory;
  final Map<Section, List<String>> destinationHistory;

  Sail()
      : sectionHistory = [Section.login],
        destinationHistory = {
          Section.login: [initialPath],
          Section.wallet: [],
          Section.manage: [],
          Section.swap: [],
          Section.settings: []
        };

  void menu() async {
    components.cubits.navbar.menuToggle();
    components.cubits.frontContainer.menuToggle();
    // we'd really like to trigger this whenever we lose focus of it...
    components.cubits.title.update(editable: false);
  }

  Future<String> back() async {
    /// todo: extra content is only used on transactions history page right now,
    ///       but we might use it elsewhere of course, so this shouldn't be
    ///       'when navigating back to /wallet/holdings' it should be based on
    ///       if that container/ cubits have anything in them. do it when
    ///       conforming the transaction history page so you can test it easily.
    // any page that uses ContentExtra layer for draggable sheets
    if (['/wallet/holdings'].contains(latestLocation)) {
      // show front layer and instantly remove extra content before anything else.
      // todo make this dependant on the map.
      components.cubits.frontContainer.setHidden(false);
      components.cubits.extraContainer.reset();
    }
    return _sailBack();
  }

  String _sailBack() {
    String location = _handleHistoryRemoval();
    final manifest = destinationMap[location]!;
    updateCubits(location, manifest, back: true);
    components.routes.navigatorKey.currentState!.pop();
    return location;
  }

  Future<void> home({
    String location = '/wallet/holdings',
    bool forceFullScreen = true,
  }) async {
    // if /wallet/holdings in DestinationHistory
    if (destinationHistory[Section.wallet]!.contains(location)) {
      while (await back() != location &&
          destinationHistory[Section.wallet]!.length > 0) {
        print('going back');
      }
    } else {
      await to(location);
    }
    if (forceFullScreen) {
      components.cubits.frontContainer
          .setHeightTo(height: FrontContainerHeight.max);
    }
  }

  Future<String?> to(
    String? location, {
    BuildContext? context,
    Section? section,
    Map<String, dynamic>? arguments,
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
      _handleHistoryAddition(
        location,
        currSection: sectionHistory.last,
        destSection: manifest.section!,
        addToDestinationHistory: addToDestinationHistory,
      );
    }
    updateCubits(location, manifest);
    if (manifest.frontPath != null &&
        RegExp(r'^\/[a-z\/]*[a-z]$').hasMatch(manifest.frontPath!)) {
      _navigate(manifest.frontPath!,
          replace: replaceOverride, context: context, arguments: arguments);
    }
    return manifest.frontPath;
  }

  /// many things are keyed off the current location so we make it available.
  /// so far nothing has to react in realtime to the path so, it's just a var.
  /// if/when we need it to notify things, we'll add it to a stream.
  void broadcast(String location, Manifest manifest) =>
      components.cubits.location
          .update(path: location, section: manifest.section);
  //latestLocation = location; // streams.app.path.add(location);

  String? get latestLocation => components.cubits.location.state.path;

  void updateCubits(String location, Manifest manifest, {bool back = false}) {
    broadcast(location, manifest);
    components.cubits.title.update(title: manifest.title);
    components.cubits.backContainer.update(path: manifest.backPath);
    // if we're going back home and we came from the menu then show the menu
    if (back &&
        ['/wallet/holdings', '/manage', '/swap'].contains(location) &&
        components.cubits.backContainer.state.path.startsWith('/menu')) {
      components.cubits.frontContainer
          .setHeightTo(height: FrontContainerHeight.min);
      components.cubits.navbar.setHeightTo(height: NavbarHeight.hidden);
    } else {
      components.cubits.frontContainer
          .setHeightTo(height: manifest.frontHeight);
      components.cubits.navbar.setHeightTo(height: manifest.navbarHeight);
    }
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
      sectionHistory.add(Section.login);
      if (destinationHistory[Section.login]!.isEmpty) {
        destinationHistory[Section.login]!.add(initialPath);
      }
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

  void _navigate(
    String path, {
    bool replace = false,
    BuildContext? context,
    Map? arguments,
  }) =>
      replace
          ? context == null
              ? components.routes.navigatorKey.currentState!
                  .pushReplacementNamed(path, arguments: arguments)
              : Navigator.of(context)
                  .pushReplacementNamed(path, arguments: arguments)
          : context == null
              ? components.routes.navigatorKey.currentState!
                  .pushNamed(path, arguments: arguments)
              : Navigator.of(context).pushNamed(path, arguments: arguments);
}
