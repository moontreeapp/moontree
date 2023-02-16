import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/settings/example.dart';
import 'package:client_front/presentation/utilities/animation.dart';

class FrontMenuLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/menu/settings',
        '/menu/security',
        '/settings/example',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [const FadeTransitionPage(child: ExampleSettingScreen())];
}
