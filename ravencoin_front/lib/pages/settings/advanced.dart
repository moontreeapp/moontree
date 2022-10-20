import 'package:flutter/material.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

import 'package:ravencoin_back/ravencoin_back.dart';

class AdvancedDeveloperOptions extends StatelessWidget {
  const AdvancedDeveloperOptions() : super();

  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => CustomScrollView(slivers: <Widget>[
        SliverToBoxAdapter(
            child: Padding(
                padding:
                    EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: SwtichChoice(
                      label: 'Advanced Developer Mode',
                      description:
                          'Unlocks experimental functionality. Use at your own risk. Make a paper backup of all wallets first.',
                      initial: pros.settings.advancedDeveloperMode,
                      onChanged: (value) async =>
                          await pros.settings.toggleAdvDevMode(value),
                    )))),
      ]);
}
