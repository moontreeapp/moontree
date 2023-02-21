// import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:client_front/application/utilities.dart';
import 'package:client_front/application/navbar/height/cubit.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/services/services.dart' show beamer;

enum Section { login, wallet, manage, swap, settings }

class Sailor {
  static const String initialPath = '/login/create';
  static const Map<Section, String> initialPaths = {
    Section.login: initialPath,
    Section.wallet: '/wallet/holdings',
    Section.manage: '/manage',
    Section.swap: '/swap',
    Section.settings: '/menu',
  };
  static const Map<String, Map<dynamic, dynamic>> destinationMap = {
    '/login/create': {
      Section: Section.login,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.hidden,
    },
    '/login/create/native': {
      Section: Section.login,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.hidden,
    },
    '/login/create/password': {
      Section: Section.login,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.hidden,
    },
    '/login/native': {
      Section: Section.login,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.hidden,
    },
    '/login/password': {
      Section: Section.login,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.hidden,
    },
    '/wallet/holdings': {
      Section: Section.wallet,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.max,
    },
    '/wallet/holding': {
      Section: Section.wallet,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.mid,
      },
      PageContainer.back: {
        'containerHeight': PageContainerHeight.mid,
      },
      NavbarHeight: NavbarHeight.mid,
    },
    '/wallet/holding/transaction': {
      Section: Section.wallet,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.mid,
    },
    '/manage': {
      Section: Section.manage,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {},
      NavbarHeight: NavbarHeight.max,
    },
    '/menu': {
      Section: Section.settings,
      PageContainer.front: {
        'path': null,
        'containerHeight': PageContainerHeight.min,
      },
      PageContainer.back: {
        'containerHeight': PageContainerHeight.max,
      },
      NavbarHeight: NavbarHeight.hidden,
    },
    '/menu/settings': {
      Section: Section.settings,
      PageContainer.front: {
        'path': null,
        'containerHeight': PageContainerHeight.min,
      },
      PageContainer.back: {
        'containerHeight': PageContainerHeight.max,
      },
      NavbarHeight: NavbarHeight.hidden,
    },
    '/settings/example': {
      Section: Section.settings,
      PageContainer.front: {
        'containerHeight': PageContainerHeight.max,
      },
      PageContainer.back: {
        'containerHeight': PageContainerHeight.same,
      },
      NavbarHeight: NavbarHeight.hidden,
    },
  };

  final BuildContext mainContext;
  late List<Section> sectionHistory;
  late Map<Section, List<String>> destinationHistory;

  Sailor({required this.mainContext}) {
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
        components.cubits.frontContainer.setHidden(false);
        components.cubits.contentExtra.reset();
      }
      sailBack();
    }
  }

  Future<void> sailTo({
    String? location,
    Section? section,
    Map<String, dynamic>? params,
    bool beam = true,
    bool addToHistory = true,
    bool? replaceOverride,
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
    final pageContainerMap = destinationMap[location];
    if (pageContainerMap == null) {
      throw Exception('Invalid location: $location');
    }
    if (addToHistory) {
      _handleHistoryAddition(
        location,
        currSection: sectionHistory.last,
        destSection: pageContainerMap[Section]!,
        addToDestinationHistory: addToDestinationHistory,
      );
    }
    // update app bar stuff
    components.cubits.title.update(path: location);
    components.cubits.navbarHeight
        .setHeightTo(height: pageContainerMap[NavbarHeight]);

    // update back stuff
    components.cubits.backContainer.update(
        child: Container(
      height: 150,
      color: Colors.yellow,
    ));
    if (pageContainerMap.isNotEmpty) {
      // update front height,
      components.cubits.frontContainer
          .setHeightTo(height: pageContainerMap['containerHeight']);

      // fade out front

      // go there
      String? matchLoc = pageContainerMap['path'];
      if (beam && matchLoc != null) {
        final matchParam = matchLoc.split(':').last;
        final ending = params?[matchLoc.split(':').last] ?? '';
        final path =
            ending == '' ? matchLoc : matchLoc.replaceFirst(matchParam, ending);
        _navigate(path, replaceOverride ?? true);
      }
    }
  }

  void sailBack() {
    //sailTo(
    //  location: _handleHistoryRemoval(),
    //  beam: true,
    //  addToHistory: false,
    //);
    // handle app bar changes
    // handle back changes
    // handle front height
    // fade out front
    Navigator.of(components.routes.scaffoldContext!).pop();
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

  void _navigate(String path, [bool replace = false]) => replace
      ? Navigator.of(components.routes.scaffoldContext!)
          .pushReplacementNamed(path)
      : Navigator.of(components.routes.scaffoldContext!).pushNamed(path);
}
