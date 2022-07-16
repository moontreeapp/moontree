// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/create.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class CreateMainAsset extends StatefulWidget {
  @override
  _CreateMainAssetState createState() => _CreateMainAssetState();
}

class _CreateMainAssetState extends State<CreateMainAsset> {
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

  Widget body() => CreateAsset(preset: FormPresets.main);
}
