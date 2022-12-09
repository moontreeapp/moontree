import 'package:flutter/material.dart';
import 'package:ravencoin_front/theme/theme.dart';

class AssetSpecBottom extends StatefulWidget {
  const AssetSpecBottom({Key? key, required this.symbol}) : super(key: key);
  final String symbol;

  @override
  _AssetSpecBottomState createState() => _AssetSpecBottomState();
}

class _AssetSpecBottomState extends State<AssetSpecBottom> {
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
    return Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 1),
        child: Row(children: <Widget>[
          if (widget.symbol.contains('/'))
            Text('${widget.symbol}/',
                style: Theme.of(context)
                    .textTheme
                    .bodyText2!
                    .copyWith(color: AppColors.offWhite))
          else
            Container(),
        ]));
  }
}
