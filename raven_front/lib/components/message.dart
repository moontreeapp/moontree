import 'package:flutter/material.dart';

class MessageComponents {
  Future<void> giveChoices(
    BuildContext context, {
    required Map<String, VoidCallback> behaviors,
    String title = 'Open in External App',
    String content = 'Open discord app or browser?',
  }) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) =>
            AlertDialog(title: Text(title), content: Text(content), actions: [
              for (var key in behaviors.keys)
                TextButton(child: Text(key), onPressed: behaviors[key]),
              //TextButton(
              //    child: Text('Continue'),
              //    onPressed: () {
              //      Navigator.of(context).pop();
              //      launch(
              //          'https://discord.gg/${link ?? name.toLowerCase()}');
              //    })
            ]));
  }
}
