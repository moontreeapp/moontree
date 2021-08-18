import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_treeview/flutter_treeview.dart';
import 'package:raven_mobile/components/buttons.dart';
import 'package:raven_mobile/styles.dart';

AppBar header(context) => AppBar(
      backgroundColor: RavenColor().appBar,
      leading: RavenButton().back(context),
      elevation: 2,
      centerTitle: false,
      title: RavenText('Technical View').h2,
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
    decoration: BoxDecoration(
      color: Colors.white,
      //borderRadius: BorderRadius.circular(10),
    ),
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
      //theme: _treeViewTheme,
    ),
  );
}
