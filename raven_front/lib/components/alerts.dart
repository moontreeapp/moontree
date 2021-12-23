import 'package:flutter/material.dart';

class AlertComponents {
  Future failure(
    BuildContext context, {
    String headline = 'Unable to create account',
    String msg = 'Please enter account name',
  }) =>
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                title: Text(headline),
                content: Text(msg),
                actions: [
                  TextButton(
                      child: Text('ok'),
                      onPressed: () => Navigator.of(context).pop())
                ],
              ));
}
