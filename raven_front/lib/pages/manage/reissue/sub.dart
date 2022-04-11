// this could be a stateless widget.

import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/widgets/widgets.dart';

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var asset =
        res.assets.bySymbol.getOne(streams.app.manage.asset.value ?? '');
    if (asset != null && asset.reissuable) {
      streams.create.form.add(GenericCreateForm(
        parent: asset.parent?.symbol,
        name: asset.symbol,
        minQuantity: asset.satsInCirculation,
        quantity: asset.satsInCirculation,
        minDecimal: asset.divisibility.toString(),
        decimal: asset.divisibility.toString(),
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

  Widget body() => ReissueAsset(preset: FormPresets.main, isSub: true);
}
