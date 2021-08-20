import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:raven_mobile/components/buttons.dart';

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
    return Scaffold(appBar: header(), body: body());
  }

  AppBar header() => AppBar(
        leading: RavenButton().back(context),
        elevation: 2,
        centerTitle: false,
        title: Text('Technical View'),
      );

  Container body() {
    const List<Map<String, dynamic>> accountsHierarchy = [
      {
        "label": "Primary",
        "children": [
          {"label": "HD Wallet", "key": "walletId"},
          {"label": "Imported Wallet 1", "key": "walletId"},
          {"label": "Imported Wallet 2", "key": "walletId"},
        ]
      },
      {
        "label": "Savings",
        "children": [
          {"label": "HD Wallet", "key": "walletId"},
        ]
      },
      {
        "label": "Other",
        "children": [
          {"label": "Imported Wallet 3", "key": "walletId"},
        ]
      },
    ];
    var _treeViewController =
        TreeViewController().loadJSON(json: jsonEncode(accountsHierarchy));
    return Container(
      padding: EdgeInsets.all(10),
      child: TreeView(
          controller: _treeViewController,
          allowParentSelect: true,
          supportParentDoubleTap: true,
          //onExpansionChanged: (key, expanded) => _expandNode(key, expanded),
          onNodeTap: (key) {
            //setState(() {
            //  _selectedNode = key;
            //  _treeViewController =
            //      _treeViewController.copyWith(selectedKey: key);
            //}
            //);
          },
          theme: TreeViewTheme(
              labelStyle: TextStyle(color: Colors.black),
              parentLabelStyle:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              colorScheme: Theme.of(context).brightness == Brightness.light
                  ? ColorScheme.light()
                  : ColorScheme.dark())
          //theme: _treeViewTheme,
          ),
    );
  }
}
