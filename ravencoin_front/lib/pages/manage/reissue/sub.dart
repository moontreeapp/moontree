// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/reissue.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class ReissueMainSubAsset extends StatefulWidget {
  @override
  _ReissueMainSubAssetState createState() => _ReissueMainSubAssetState();
}

class _ReissueMainSubAssetState extends State<ReissueMainSubAsset> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    streams.reissue.form.add(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Asset? asset = pros.assets.primaryIndex.getOne(
        streams.app.manage.asset.value ?? '',
        pros.settings.chain,
        pros.settings.net);
    if (asset != null && asset.reissuable) {
      streams.reissue.form.add(GenericReissueForm(
        parent: asset.parent?.symbol,
        name: asset.symbol,
        minQuantity: asset.amount,
        minDecimal: asset.divisibility,
        decimal: asset.divisibility,
        minIpfs: asset.data,
        ipfs: asset.data,
        reissuable: asset.reissuable,
      ));
      return BackdropLayers(
          back: const BlankBack(),
          front: FrontCurve(
              child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: body(),
          )));
    }
    return BackdropLayers(
        back: const BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Text('unable to reissue ${asset?.symbol}'),
        )));
  }

  Widget body() => const ReissueAsset(preset: FormPresets.main, isSub: true);
}
