import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/components/components.dart';

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
      back: const BlankBack(),
      front: FrontCurve(
        child: Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //SizedBox(height: 40),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Ravencoin',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        const SizedBox(height: 8),
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Join the Ravencoin Discord for general Ravencoin discussions.',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        const SizedBox(height: 16),
                        const Divider(indent: 0),
                        const SizedBox(height: 16),
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Evrmore',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        const SizedBox(height: 8),
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Join the Evrmore Discord for general Evrmore discussions.',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        const SizedBox(height: 16),
                        const Divider(indent: 0),
                        const SizedBox(height: 16),
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Moontree',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        const SizedBox(height: 8),
                        Padding(
                            padding: const EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Join the Moontree Discord, where you can see frequently asked questions, find solutions and request help.',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                      ]),
                  components.containers.navBar(context,
                      tall: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                actionButton(
                                  context,
                                  name: 'RAVENCOIN',
                                  link: 's2nc6ecNR3',
                                ),
                                const SizedBox(width: 16),
                                actionButton(
                                  context,
                                  name: 'EVRMORE',
                                  link: 'B87dQ83Swb',
                                ),
                              ]),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: <Widget>[
                                actionButton(
                                  context,
                                  name: 'MOONTREE',
                                  link: 'cGDebEXgpW',
                                ),
                              ]),
                          const SizedBox(width: 16),
                        ],
                      )),
                ])),
      ),
    );
  }

  Widget actionButton(
    BuildContext context, {
    required String name,
    String? link,
  }) =>
      components.buttons.actionButton(
        context,
        label: name.toUpperCase(),
        onPressed: () async => components.message.giveChoices(
          context,
          title: 'Open in External App',
          content: 'Open discord app or browser?',
          behaviors: {
            'Cancel': Navigator.of(context).pop,
            'Continue': () {
              Navigator.of(context).pop();
              launchUrl(Uri.parse(
                  'https://discord.gg/${link ?? name.toLowerCase()}'));
            },
          },
        ),
      );
}
