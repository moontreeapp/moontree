import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/menu/menu.dart';
import 'package:client_front/presentation/pagesv2/menu/settings.dart';
import 'package:client_front/presentation/utilities/animation.dart';

class BackMenuLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/menu', '/menu/settings'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        if (state.uri.path == '/menu')
          const FadeTransitionPage(child: BackMenuScreen()),
        if (state.uri.path == '/menu/settings')
          const FadeTransitionPage(child: BackMenuSettingsScreen())
      ];
}
