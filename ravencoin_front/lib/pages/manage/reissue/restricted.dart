// this could be a stateless widget.
import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/reissue.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

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
    streams.reissue.form.add(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var asset = pros.assets.primaryIndex.getOne(
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
