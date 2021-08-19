import 'package:flutter/material.dart';

import 'package:raven_mobile/components/pages/asset.dart' as asset;
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';
import 'package:raven_mobile/services/account_mock.dart' as mock;

class Asset extends StatefulWidget {
  final dynamic data;
  const Asset({this.data}) : super();

  @override
  _AssetState createState() => _AssetState();
}

class _AssetState extends State<Asset> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //data = data.isNotEmpty ??
    //    data ??
    //    ModalRoute.of(context)!.settings.arguments ??
    data = {
      'account': 'accountId2',
      'accounts': mock.Accounts.instance.accounts,
      'transactions': mock.Accounts.instance.transactions,
      'holdings': mock.Accounts.instance.holdings,
    };
    return DefaultTabController(
        length: 2,
        child: Scaffold(
            appBar: asset.header(context),
            body: asset.transactionsMetadataView(context, data),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            floatingActionButton: asset.sendReceiveButtons(context),
            bottomNavigationBar: RavenButton().bottomNav(context)));
  }
}
