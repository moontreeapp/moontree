import 'package:flutter/material.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/infrastructure/services/storage.dart';

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
            style: Theme.of(context).textTheme.bodyLarge),
        Text(
          'DO NOT DO THIS. EVER.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        Row(children: <Widget>[
          components.buttons.actionButtonSoft(
            context,
            label: 'Clear Secure Storage',
            onPressed: () async {
              await components.message.giveChoices(context,
                  title: 'Are you sure?',
                  content: "don't do it.",
                  behaviors: <String, void Function()>{
                    'CANCEL': () => Navigator.of(context).pop(),
                    'DO IT': () async => components.message.giveChoices(context,
                            title: 'Are you really sure?',
                            content:
                                "Look, don't want to do this. You wont be able to login anymore. I mean at least go back and make a paper backup first. The only real reason to do this is for testing purposes or in preparation of erasing the app from your device entirely.",
                            behaviors: <String, void Function()>{
                              'CANCEL': () {
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                              'ACTUALLY DO IT': () async {
                                await SecureStorage.deleteAll();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                                streams.app.behavior.snack.add(
                                    Snack(message: 'Secure Storage Cleared'));
                              }
                            })
                  });
            },
          )
        ])
      ]);
}
