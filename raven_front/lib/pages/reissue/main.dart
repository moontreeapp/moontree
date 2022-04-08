// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/widgets/widgets.dart';

class ReissueMainAsset extends StatefulWidget {
  @override
  _ReissueMainAssetState createState() => _ReissueMainAssetState();
}

class _ReissueMainAssetState extends State<ReissueMainAsset> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    streams.create.form.add(GenericCreateForm());
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => ReissueAsset(preset: FormPresets.main);
}
