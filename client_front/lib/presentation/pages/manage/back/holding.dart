import 'package:flutter/material.dart';
import 'package:client_front/presentation/widgets/back/coinspec/spec.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class BackManageHoldingScreen extends StatelessWidget {
  final String chainSymbol;
  const BackManageHoldingScreen({Key? key, this.chainSymbol = ''})
      : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('backHolding');

  @override
  Widget build(BuildContext context) => Container(
        height: screen.frontContainer.inverseMid,
        alignment: Alignment.center,
        child: CoinDetailsHeader(),
      );
}

class CoinDetailsHeader extends StatelessWidget {
  const CoinDetailsHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => CoinSpec(
        pageTitle: 'Asset',
        security: components.cubits.location.state.security,
        bottom: components.cubits.manageHoldingView.nullCacheView
            ? null
            : Container(),
      );
}
