// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/create.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class CreateQualifierSubAsset extends StatefulWidget {
  @override
  _CreateQualifierSubAssetState createState() =>
      _CreateQualifierSubAssetState();
}

class _CreateQualifierSubAssetState extends State<CreateQualifierSubAsset> {
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
    streams.create.form
        .add(GenericCreateForm(parent: streams.app.manage.asset.value));
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => CreateAsset(preset: FormPresets.qualifier, isSub: true);
}
