import 'package:flutter/material.dart';

class LoginNative extends StatelessWidget {
  const LoginNative({Key? key}) : super(key: key ?? defaultKey);
  static const defaultKey = ValueKey('frontLoginNative');

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
