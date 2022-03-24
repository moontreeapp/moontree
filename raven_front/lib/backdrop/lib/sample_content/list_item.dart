import 'package:flutter/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8),
      child: Container(
          child: const ListTile(
        title: Text('List Item'),
        leading: Icon(Icons.people),
      )),
    );
  }
}
