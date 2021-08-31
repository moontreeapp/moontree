import 'package:flutter/material.dart';

import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';

class Transaction extends StatefulWidget {
  final dynamic data;
  const Transaction({this.data}) : super();

  @override
  _TransactionState createState() => _TransactionState();
}

class _TransactionState extends State<Transaction> {
  dynamic data = {};

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    var metadata = false;
    // how do we detect metadata?
    /*Tron — Yesterday at 6:51 PM
      You can add messages to transactions by putting the IPFS hash of the message in the OP_RETURN.
      They're called memos. They will be public.*/
    return DefaultTabController(
        length: metadata ? 2 : 1,
        child: Scaffold(
            appBar: header(metadata),
            body: body(metadata),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
            bottomNavigationBar: RavenButton.bottomNav(context)));
  }

  PreferredSize header(bool metadata) => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.34),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: RavenButton.back(context),
          actions: <Widget>[
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: RavenButton.settings(context))
          ],
          title: Text('Transaction'),
          flexibleSpace: Container(
              alignment: Alignment.center,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 15.0),
                    RavenIcon.assetAvatar(data['transaction']!.security.symbol),
                    SizedBox(height: 15.0),
                    Text(data['transaction']!.security.symbol,
                        style: Theme.of(context).textTheme.headline4),
                    SizedBox(height: 15.0),
                    Text('Received',
                        style: Theme.of(context).textTheme.headline5),
                  ])),
          bottom: PreferredSize(
              preferredSize: Size.fromHeight(50.0),
              child: TabBar(tabs: [
                Tab(text: 'Details'),
                ...(metadata ? [Tab(text: 'Memo')] : [])
              ]))));

  TabBarView body(bool metadata) => TabBarView(children: [
        ListView(shrinkWrap: true, padding: EdgeInsets.all(20.0), children: <
            Widget>[
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(
                'Date: June 26 2021', // estimated date based on (current height - data['transaction']!.height)
                style: TextStyle(color: Theme.of(context).disabledColor)),
            Text(
                'Confirmaitons: 60+', // current height - data['transaction']!.height
                style: TextStyle(color: Theme.of(context).disabledColor)),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
              Widget>[
            SizedBox(height: 15.0),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text:
                      'rtahoe5eu4e4ea451ea21e445euaeu454' //// data['transaction']!.scripthash - get address of...
                  ),
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'To',
                  hintText: 'Address'),
            ),
            SizedBox(height: 15.0),
            TextField(
              readOnly: true,
              controller: TextEditingController(
                  text: data['transaction']!.value.toString()),
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                  hintText: 'Quantity'),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('fee',
                  style: TextStyle(color: Theme.of(context).disabledColor)),
              Text('0.01397191 RVN',
                  style: TextStyle(color: Theme.of(context).disabledColor)),
            ]),
            SizedBox(height: 15.0),
            TextField(
              readOnly: true,
              controller:
                  TextEditingController(text: data['transaction']!.note),
              keyboardType: TextInputType.multiline,
              maxLines: null,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Note',
                  hintText: 'Note to Self'),
            ),
            SizedBox(height: 15.0),
            Text('id: ' + data['transaction']!.hash,
                style: TextStyle(color: Theme.of(context).disabledColor)),
            SizedBox(height: 15.0),
            // replaced by tab, missing if metadata is missing...
            //ElevatedButton.icon(
            //    onPressed: () {},
            //    icon: Icon(Icons.description),
            //    label: Text('Metadata'))
          ])
        ]),
        ...(metadata ? [Text('None')] : [])
      ]);
}
