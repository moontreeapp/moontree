import 'package:flutter/material.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class DeveloperOptions extends StatelessWidget {
  const DeveloperOptions() : super();

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
                    child: DeveloperModeChoice()))),
      ]);
}
