import 'package:flutter/material.dart';

class ExampleSettingScreen extends StatelessWidget {
  const ExampleSettingScreen({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontFrontMenu');

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topRight,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 16),
            height: 56,
            child: const Text(
              style: TextStyle(color: Colors.black),
              'some example setting thing',
            ),
          ),
        ],
      ),
    );
  }
}
