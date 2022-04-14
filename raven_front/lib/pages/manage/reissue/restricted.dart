// this could be a stateless widget.
import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/reissue.dart';
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
    var asset =
        res.assets.bySymbol.getOne(streams.app.manage.asset.value ?? '');
    if (asset != null && asset.reissuable) {
      streams.reissue.form.add(GenericReissueForm(
        parent: asset.parent?.symbol,
        name: asset.symbol,
        minQuantity: asset.amount.toInt(),
        minDecimal: asset.divisibility,
        decimal: asset.divisibility,
        minIpfs: asset.ipfs,
        ipfs: asset.ipfs,
        reissuable: asset.reissuable,
      ));
      return BackdropLayers(
          back: BlankBack(),
          front: FrontCurve(
              child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: body(),
          )));
    }
    return BackdropLayers(
        back: BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Text('unable to reissue ${asset?.symbol}'),
        )));
  }

  Widget body() => ReissueAsset(preset: FormPresets.restricted);
}
