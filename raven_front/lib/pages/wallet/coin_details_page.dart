import 'package:flutter/material.dart';

import '../../widgets/back/coinspec/spec.dart';

class CoinDetailsPage extends StatefulWidget {
  const CoinDetailsPage({ Key? key }) : super(key: key);

  @override
  State<CoinDetailsPage> createState() => _CoinDetailsPageState();
}

class _CoinDetailsPageState extends State<CoinDetailsPage> {


  DraggableScrollableController dController = DraggableScrollableController();
  ValueNotifier<double> _notifier = ValueNotifier(1);


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      
    );
  }
}

class CoinSpecWidget extends StatelessWidget {
  const CoinSpecWidget({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   CoinSpec(
          // pageTitle: 'Transactions',
          // security: security,
          // bottom: cachedMetadataView != null ? null : Container(),
        );
  }
}