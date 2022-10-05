import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart';

class ClearSSChoice extends StatefulWidget {
  final dynamic data;
  const ClearSSChoice({this.data}) : super();

  @override
  _ClearSSChoice createState() => _ClearSSChoice();
}

class _ClearSSChoice extends State<ClearSSChoice> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
        Text('Clear Secure Storage',
            style: Theme.of(context).textTheme.bodyText1),
        Text(
          'DO NOT DO THIS. EVER.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        Row(children: [
          components.buttons.actionButton(
            context,
            enabled: true,
            label: 'Clear Secure Storage',
            onPressed: () async {
              await components.message.giveChoices(context,
                  title: 'Are you sure?',
                  content: "don't do it.",
                  behaviors: {
                    'CANCEL': () => Navigator.of(context).pop(),
                    'DO IT': () async => await components.message.giveChoices(
                            context,
                            title: 'Are you really sure?',
                            content:
                                "Look, buddy, you do this and you can't login anymore. I mean at least go back and make a paper backup first if you're gonna do this. The only real reason to do this is if you want to erase the app from your device entirely.",
                            behaviors: {
                              'CANCEL': () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              'ACTUALLY DO IT': () async {
                                await SecureStorage.deleteAll();
                              }
                            })
                  });
            },
          )
        ])
      ]);
}
