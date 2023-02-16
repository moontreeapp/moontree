import 'package:flutter/material.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_back/client_back.dart';

class DatabaseOptions extends StatelessWidget {
  const DatabaseOptions() : super();

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
                    left: 16, right: 16, top: 16, bottom: 16),
                child: Container(
                    alignment: Alignment.topLeft,
                    child: const ResyncChoice()))),
        if (services.developer.advancedDeveloperMode)
          SliverToBoxAdapter(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  child: Container(
                      alignment: Alignment.topLeft,
                      child: const ClearSSChoice()))),
      ]);
}
