import 'package:flutter/material.dart';
import 'package:raven_front/theme/theme.dart';

class AssetSpecBottom extends StatefulWidget {
  final String symbol;

  AssetSpecBottom({Key? key, required this.symbol}) : super(key: key);

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
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 1),
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          widget.symbol.contains('/')
              ? Text('${widget.symbol}/',
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2!
                      .copyWith(color: AppColors.offWhite))
              : Container(),
        ]));
  }
}
