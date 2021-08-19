import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/technical.dart' as technical;
import 'package:raven_mobile/styles.dart';

class TechnicalView extends StatefulWidget {
  final dynamic data;
  const TechnicalView({this.data}) : super();

  @override
  _TechnicalViewState createState() => _TechnicalViewState();
}

class _TechnicalViewState extends State<TechnicalView> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: technical.header(context), body: technical.body());
  }
}
