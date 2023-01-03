import 'package:flutter/material.dart';
import 'package:client_front/widgets/widgets.dart';

class BlockchainChoices extends StatelessWidget {
  const BlockchainChoices() : super();

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: const BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
            child: Padding(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 0, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: const BlockchainChoice()))),
        const ElectrumNetwork(),
      ]);
}
