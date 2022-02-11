// this could be a stateless widget.
import 'package:flutter/material.dart';
import 'package:raven_front/widgets/widgets.dart';

class CreateRestrictedAsset extends StatefulWidget {
  @override
  _CreateRestrictedAssetState createState() => _CreateRestrictedAssetState();
}

class _CreateRestrictedAssetState extends State<CreateRestrictedAsset> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  Widget body() => CreateAsset(preset: FormPresets.restricted);
}
