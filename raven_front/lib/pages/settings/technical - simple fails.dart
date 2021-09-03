/// clicking the Accounts name should take you to the accounts technical view
/// where you can move, rename, reorder (must be saved in new reservoir or on
/// accounts objects), delete, move wallets and view details.

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:raven/raven.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/components/icons.dart';

//import 'package:flutter_treeview/flutter_treeview.dart';
/// make our own 2-layer hierarchy view
/// use draggable to move things between the levels:
///
/// view Balances? should be easy balances are saved by wallet and by account...
///
/// header [ import -> import page, export all accounts -> file]
/// spacer (drag target) [ reorder accounts by dragging ]
/// account [ renamable by click ] (drag target) [ delete, import-> set that account as current and go to import page, export -> file ]
///   wallet [ type and id... ] (draggable) [ delete, view details?, export -> show private key or seed phrase ]
///
/// account order will be saved in settings:
/// settings.accountOrder List
/// settings.saveAccountOrder(List<String> accountIds)

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
    settings.changes.listen((changes) {
      setState(() {});
    });
    //wallets.changes.listen((changes) {
    //  setState(() {});
    //});
    //accounts.changes.listen((changes) {
    //  setState(() {});
    //});
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments;
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: RavenButton.back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Technical View'),
      );
  List<String> item = [
    "Clients",
    "Designer",
    "Developer",
    "Director",
    "Employee",
    "Manager",
    "Worker",
    "Owner"
  ];
  void reorderData(int oldindex, int newindex) {
    setState(() {
      if (newindex > oldindex) {
        newindex -= 1;
      }
      final items = item.removeAt(oldindex);
      item.insert(newindex, items);
    });
  }

  ReorderableListView body() {
    return ReorderableListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      //header: _header(),
      children: <Widget>[
        for (final items in item)
          Card(
            color: Colors.blueGrey,
            key: ValueKey(items),
            elevation: 2,
            child: ListTile(
              title: Text(items),
              leading: Icon(
                Icons.work,
                color: Colors.black,
              ),
            ),
          ),
      ],
      onReorder: reorderData,
    );

    //Column(children: <Widget>[
    //  _heading(),
    //  _accounts(),
    //]);
  }

  ListTile _header() => ListTile(
        onTap: () {},
        onLongPress: () {},
        leading: RavenIcon.appAvatar(),
        title:
            Text('All Accounts', style: Theme.of(context).textTheme.bodyText1),
        //trailing: [ import -> import page, export all accounts -> file],
      );
}
