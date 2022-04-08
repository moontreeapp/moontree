// this could be a stateless widget.
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/widgets/widgets.dart';

class ReissueRestrictedAsset extends StatefulWidget {
  @override
  _ReissueRestrictedAssetState createState() => _ReissueRestrictedAssetState();
}

class _ReissueRestrictedAssetState extends State<ReissueRestrictedAsset> {
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

  Widget body() => ReissueAsset(preset: FormPresets.restricted);
}
