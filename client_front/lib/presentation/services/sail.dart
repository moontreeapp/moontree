// import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pages/splash.dart';
import 'package:client_front/presentation/widgets/back/menu.dart';
import 'package:flutter/material.dart';

import 'package:client_back/streams/streams.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/application/navbar/height/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

enum Section { login, wallet, manage, swap, settings }

class Manifest {
  final Section? section;
  final String? backPath;
  final PageContainerHeight frontHeight;
  final NavbarHeight navbarHeight;
  final String? frontPath;
  final Widget? extraChild;
  final bool extraHideFront;
  const Manifest({
    this.section,
    this.backPath,
    this.frontHeight = PageContainerHeight.same,
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
    '/backup/intro': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/intro',
    ),
    '/backup/seed': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/seed',
    ),
    '/backup/keypair': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/keypair',
    ),
    '/backup/verify': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/backup/verify',
    ),
    '/wallet/holdings': Manifest(
      section: Section.wallet,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/wallet/holdings',
      backPath: '/menu',
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
      backPath: '/menu',
    ),

    /// removed as a route. simplified a lot.
    //'/menu': Manifest(
    //  section: Section.settings,
    //  frontHeight: PageContainerHeight.min,
    //  navbarHeight: NavbarHeight.hidden,
    //  frontPath: null,
    //),
    //'/menu/settings': Manifest(
    //  section: Section.settings,
    //  frontHeight: PageContainerHeight.min,
    //  navbarHeight: NavbarHeight.hidden,
    //  frontPath: null,
    //),
    '/settings/example': Manifest(
      section: Section.settings,
      frontHeight: PageContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/settings/example',
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

  String? latestLocation;

  void menu() async => components.cubits.frontContainer.menuToggle();

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
    return sailBack();
  }

  Future<void> home([String location = '/wallet/holdings']) async {
    // if /wallet/holdings in DestinationHistory
    if (destinationHistory[Section.wallet]!.contains(location)) {
      while (await back() != location &&
          destinationHistory[Section.wallet]!.length > 0) {
        print('going back');
      }
    } else {
      await to(location);
    }
  }
  //Future<void> backTo(String location) async {
  //  try {
  //    Navigator.of(context).popUntil(ModalRoute.withName('/home'));
  //  } catch (e) {
  //    print('home not found');
  //    Navigator.of(context).pushReplacementNamed('/home');
  //  }
  //}

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
    if (manifest.frontPath != null &&
        RegExp(r'^\/[a-z\/]*[a-z]$').hasMatch(manifest.frontPath!)) {
      // todo: get rid of this pattern, just pass args in if you want.
      //final matchParam = manifest.frontPath!.split(':').last;
      //final ending = arguments?[manifest.frontPath!.split(':').last] ?? '';
      //final path = ending == ''
      //    ? manifest.frontPath!
      //    : manifest.frontPath!.replaceFirst(matchParam, ending);
      _navigate(manifest.frontPath!,
          replace: replaceOverride, context: context, arguments: arguments);
    }
    return manifest.frontPath;
  }

  String sailBack() {
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
    return location;
  }

  /// many things are keyed off the current location so we make it available.
  /// so far nothing has to react in realtime to the path so, it's just a var.
  /// if/when we need it to notify things, we'll add it to a stream.
  void broadcast(String location) =>
      latestLocation = location; // streams.app.path.add(location);

  void updateCubits(String location, Manifest manifest) {
    broadcast(location);

    // update app bar stuff
    components.cubits.title.update(path: location);

    // update nav bar stuff
    //components.cubits.navbarHeight.setHeightTo(height: manifest.navbarHeight);

    // update back stuff
    components.cubits.backContainer.update(path: manifest.backPath);

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
  //? Navigator.of(context ?? components.routes.routeContext!)
  //    .pushReplacementNamed(path)
  //: Navigator.of(context ?? components.routes.routeContext!)
  //    .pushNamed(path);
  // !.push(MaterialPageRoute(builder: (context) => MyPage()),);
}
