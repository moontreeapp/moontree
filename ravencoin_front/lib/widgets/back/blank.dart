import 'package:flutter/material.dart';

class BlankBack extends StatelessWidget {
  BlankBack({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(color: Theme.of(context).backgroundColor);
  }
}
