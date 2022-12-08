// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/create.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class CreateMainSubAsset extends StatefulWidget {
  @override
  _CreateMainSubAssetState createState() => _CreateMainSubAssetState();
}

class _CreateMainSubAssetState extends State<CreateMainSubAsset> {
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
        back: const BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => const CreateAsset(preset: FormPresets.main, isSub: true);
}
