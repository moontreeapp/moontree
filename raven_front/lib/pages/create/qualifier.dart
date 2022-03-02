// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/widgets/widgets.dart';

class CreateQualifierAsset extends StatefulWidget {
  @override
  _CreateQualifierAssetState createState() => _CreateQualifierAssetState();
}

class _CreateQualifierAssetState extends State<CreateQualifierAsset> {
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

  Widget body() => CreateAsset(preset: FormPresets.qualifier);
}
