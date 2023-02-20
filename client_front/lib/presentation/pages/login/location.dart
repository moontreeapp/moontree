import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/utilities/animation.dart';
import 'package:client_front/presentation/pages/login/create.dart';
import 'package:client_front/presentation/pages/login/create_native.dart';
import 'package:client_front/presentation/pages/login/create_password.dart';
import 'package:client_front/presentation/pages/login/native.dart';
import 'package:client_front/presentation/pages/login/password.dart';

class FrontLoginLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/login/create',
        '/login/create/native',
        '/login/create/password',
        '/login/native',
        '/login/password',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => () {
        print(state.uri.path);
        return [
          if (state.uri.path == '/login/create')
            const FadeTransitionPage(child: FrontCreateScreen()),
          if (state.uri.path == '/login/create/native')
            const BeamPage(child: FrontCreateNativeScreen()),
          //const FadeTransitionPage(child: FrontCreateNativeScreen()),
          if (state.uri.path == '/login/create/password')
            const FadeTransitionPage(child: FrontCreatePasswordScreen()),
          if (state.uri.path == '/login/native')
            const FadeTransitionPage(child: FrontNativeScreen()),
          if (state.uri.path == '/login/password')
            const FadeTransitionPage(child: FrontPasswordScreen()),
        ];
      }();
}
