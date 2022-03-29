import 'package:flutter/material.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/widgets/widgets.dart';

class Asset extends StatefulWidget {
  const Asset() : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  Map<String, dynamic> data = {};

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    var symbol = data['symbol'] as String;
    return Column(
      children: [Expanded(child: AssetDetails(symbol: symbol)), NavBar()],
    );
  }
}
