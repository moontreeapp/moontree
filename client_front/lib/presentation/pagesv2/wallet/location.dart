import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:client_front/presentation/pagesv2/wallet/front_holdings.dart';
import 'package:client_front/presentation/pagesv2/wallet/front_holding.dart';
import 'package:client_front/presentation/pagesv2/wallet/back_holding.dart';
import 'package:client_front/presentation/utilities/animation.dart';

class FrontWalletLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/wallet/holdings',
        '/wallet/holding',
        '/wallet/holding/transaction',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        if (state.uri.pathSegments.contains('holdings'))
          const FadeTransitionPage(child: FrontHoldingsScreen()),
        if (state.uri.pathSegments.contains('holding'))
          const FadeTransitionPage(child: FrontHoldingScreen()),
      ];
}

class BackWalletLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/wallet/holding/:chainSymbol'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        if (state.uri.pathSegments.contains('holding'))
          FadeTransitionPage(
            key: ValueKey(
                'backHolding${state.pathParameters['chainSymbol']?.substring(1) ?? ''}'),
            child: BackHoldingScreen(
                chainSymbol:
                    (state.pathParameters['chainSymbol']?.substring(1) ?? '')),
          ),
      ];
}
