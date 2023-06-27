import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

class SupportPage extends StatelessWidget {
  const SupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageStructure(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Ravencoin',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Join the Ravencoin Discord for general Ravencoin discussions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(indent: 0),
          Text(
            'Evrmore',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Join the Evrmore Discord for general Evrmore discussions.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Divider(indent: 0),
          Text(
            'Moontree',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          Text(
            'Join the Moontree Discord, where you can see frequently asked questions, find solutions and request help.',
            style: Theme.of(context).textTheme.bodyLarge,
          )
        ],
        firstLowerChildren: <Widget>[
          SupportAction(
            name: 'RAVENCOIN',
            link: 's2nc6ecNR3',
          ),
          SupportAction(
            name: 'EVRMORE',
            link: 'B87dQ83Swb',
          ),
        ],
        secondLowerChildren: <Widget>[
          SupportAction(
            name: 'MOONTREE',
            link: 'cGDebEXgpW',
          ),
        ]);
  }
}

class SupportAction extends StatelessWidget {
  final String name;
  final String? link;
  const SupportAction({Key? key, required this.name, this.link})
      : super(key: key);

  @override
  Widget build(BuildContext context) => BottomButton(
      label: name.toUpperCase(),
      onPressed: () async => components.cubits.messageModal.update(
            title: name,
            content: 'Open Discord?',
            behaviors: <String, void Function()>{
              'Cancel': components.cubits.messageModal.reset,
              'Continue': () {
                components.cubits.messageModal.reset();
                launchUrl(Uri.parse(
                    'https://discord.gg/${link ?? name.toLowerCase()}'));
              },
            },
          ));
}
