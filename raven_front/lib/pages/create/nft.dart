// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:raven_front/widgets/widgets.dart';

class CreateNFTAsset extends StatefulWidget {
  @override
  _CreateNFTAssetState createState() => _CreateNFTAssetState();
}

class _CreateNFTAssetState extends State<CreateNFTAsset> {
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

  Widget body() => CreateAsset(preset: FormPresets.NFT, parent: 'Parent');
}
