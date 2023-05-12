import 'package:flutter/material.dart';
import 'package:client_front/application/utilities.dart';
import 'package:client_front/application/layers/navbar/cubit.dart';
import 'package:client_front/application/infrastructure/location/cubit.dart';
import 'package:client_front/presentation/pages/wallet/front/holding.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/utils/animation.dart' as animation;

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
    Section.manage: '/manage/holdings',
    Section.swap: '/swap/holdings',
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
    '/login/verify': Manifest(
      title: 'Security',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/verify',
    ),
    '/login/modify/password': Manifest(
      title: 'Security',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/login/modify/password',
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
      title: 'Holdings', // gets overridden with wallet name
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/wallet/holdings',
      backPath: '/menu',
    ),
    '/wallet/holding': Manifest(
      title: 'Holding', // gets overridden with holding name
      section: Section.wallet,
      frontHeight: FrontContainerHeight.mid,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/wallet/holding',
      extraChild: const FrontHoldingExtra(),
      backPath: '/wallet/holding/coinspec',
    ),
    '/wallet/holding/transaction': Manifest(
      title: 'Transaction',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/wallet/holding/transaction',
      backPath: '/',
    ),
    '/receive': Manifest(
      title: 'Receive',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/receive',
      backPath: '/',
    ),
    '/wallet/send': Manifest(
      title: 'Send',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.mid,
      navbarHeight: NavbarHeight.hidden, // should be replaced with 'preview'
      frontPath: '/wallet/send',
      backPath: '/wallet/send/coinspec',
    ),
    '/wallet/send/checkout': Manifest(
      title: 'Checkout',
      section: Section.wallet,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/wallet/send/checkout',
      backPath: '/',
    ),
    '/manage/holdings': Manifest(
      title: 'Manage', // gets overridden with wallet name
      section: Section.manage,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/manage/holdings',
      backPath: '/menu',
    ),
    '/manage/holding': Manifest(
      title: 'Manage', // gets overridden with holding name
      section: Section.manage,
      frontHeight: FrontContainerHeight.mid,
      navbarHeight: NavbarHeight.mid,
      frontPath: '/manage/holding',
      extraChild: const FrontHoldingExtra(),
      backPath: '/manage/holding/coinspec',
    ),
    '/manage/reissue': Manifest(
      title: 'Reissue',
      section: Section.manage,
      frontHeight: FrontContainerHeight.mid,
      navbarHeight: NavbarHeight.hidden, // should be replaced with 'preview'
      frontPath: '/manage/reissue',
      backPath: '/manage/reissue/coinspec',
    ),
    '/manage/reissue/checkout': Manifest(
      title: 'Checkout',
      section: Section.manage,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/manage/reissue/checkout',
      backPath: '/',
    ),
    '/swap/holdings': Manifest(
      title: 'Swap',
      section: Section.swap,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.max,
      frontPath: '/swap/holdings',
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
    '/mode/developer': Manifest(
      title: 'Developer Mode',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/mode/developer',
    ),
    '/mode/advanced': Manifest(
      title: 'Advanced Developer Mode',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/mode/advanced',
    ),
    '/setting/mining': Manifest(
      title: 'Mining Settings',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/setting/mining',
    ),
    '/setting/database': Manifest(
      title: 'Database Settings',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/setting/database',
    ),
    '/setting/security': Manifest(
      title: 'Security Settings',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/setting/security',
    ),
    '/network/blockchain': Manifest(
      title: 'Blockchain Settings',
      section: Section.settings,
      frontHeight: FrontContainerHeight.max,
      navbarHeight: NavbarHeight.hidden,
      frontPath: '/network/blockchain',
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

  void menu({bool? open}) async {
    if ((open == null && components.cubits.location.state.menuOpen) ||
        open == false) {
      components.cubits.navbar.closeMenu();
      components.cubits.frontContainer.closeMenu();
      components.cubits.location.update(menuOpen: false);
    } else if ((open == null && !components.cubits.location.state.menuOpen) ||
        open == true) {
      components.cubits.navbar.openMenu();
      components.cubits.frontContainer.openMenu();
      components.cubits.location.update(menuOpen: true);
    } else {
      return;
    }
    //components.cubits.navbar.menuToggle();
    //components.cubits.frontContainer.menuToggle();
    // we'd really like to trigger this whenever we lose focus of it...
    components.cubits.title.update(editable: false);
  }

  String back() {
    String location = _handleHistoryRemoval();
    final manifest = destinationMap[location]!;
    updateCubits(location, manifest, back: true);
    print(
        'components.routes.navigatorKey.currentState ${components.routes.navigatorKey.currentState}');
    components.routes.navigatorKey.currentState!.pop(); // ? should we do this?
    return location;
  }

  void home({bool forceFullScreen = true}) {
    void perSection({Section? section}) {
      if (section == null) {
        section == Section.wallet;
      }
      final String location = '/${section!.name}/holdings';
      if (components.cubits.location.state.path != location) {
        if (destinationHistory[section]!.contains(location)) {
          while (
              back() != location && destinationHistory[section]!.length > 0) {
            print('going back');
          }
        } else {
          to(location);
        }
      }
    }

    perSection(section: components.cubits.location.state.sector);
    if (components.cubits.location.state.menuOpen) {
      menu(open: false);
    }
    if (forceFullScreen) {
      components.cubits.frontContainer
          .setHeightTo(height: FrontContainerHeight.max);
      components.cubits.navbar.setHeightTo(height: NavbarHeight.mid);
    }
  }

  String? to(
    String? location, {
    BuildContext? context,
    Section? section,
    String? symbol,
    Map<String, dynamic>? arguments,
    bool addToHistory = true,
    bool replaceOverride = false,
  }) {
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
    if (replaceOverride) {
      _handleHistoryRemoval();
    }
    if (addToHistory) {
      _handleHistoryAddition(
        location,
        currSection: sectionHistory.last,
        destSection: manifest.section,
        addToDestinationHistory: addToDestinationHistory,
      );
    }
    updateCubits(location, manifest, symbol: symbol);
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
  void broadcast(String location, Manifest manifest, String? symbol) =>
      components.cubits.location
          .update(path: location, section: manifest.section, symbol: symbol);

  String? get latestLocation => components.cubits.location.state.path;

  void updateCubits(
    String location,
    Manifest manifest, {
    String? symbol,
    bool back = false,
  }) {
    if ( //back && // removing this fixed the receive from tx history page
        manifest.extraChild == null &&
            components.cubits.extraContainer.state.child != null) {
      components.cubits.extraContainer.reset();
      if (manifest.frontHeight != FrontContainerHeight.hidden) {
        components.cubits.frontContainer.setHidden(false);
      }
    }
    broadcast(location, manifest, symbol);
    components.cubits.title.update(title: manifest.title);
    // if we're going back home and we came from the menu then show the menu
    if (back &&
        ['/wallet/holdings', '/manage/holdings', '/swap/holdings']
            .contains(location) &&
        components.cubits.location.state.menuOpen) {
      components.cubits.frontContainer
          .setHeightTo(height: FrontContainerHeight.min);
      components.cubits.navbar.setHeightTo(height: NavbarHeight.hidden);
    } else {
      components.cubits.frontContainer
          .setHeightTo(height: manifest.frontHeight);
      components.cubits.navbar.setHeightTo(height: manifest.navbarHeight);
    }
    components.cubits.backContainer.update(path: manifest.backPath);
    Future.delayed(animation.slideDuration).then((_) async {
      components.cubits.extraContainer.set(child: manifest.extraChild);
    });
  }

  /// mutates history state
  void _handleHistoryAddition(
    String location, {
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
                  .popAndPushNamed(path, arguments: arguments)
              //.pushReplacementNamed(path, arguments: arguments)
              : Navigator.of(context)
                  .popAndPushNamed(path, arguments: arguments)
          //.pushReplacementNamed(path, arguments: arguments)
          : context == null
              ? components.routes.navigatorKey.currentState!
                  .pushNamed(path, arguments: arguments)
              : Navigator.of(context).pushNamed(path, arguments: arguments);
}
