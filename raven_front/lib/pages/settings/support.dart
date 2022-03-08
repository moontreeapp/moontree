import 'package:flutter/material.dart';

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            //SizedBox(height: 40),
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'RAVENCOIN',
                    style: Theme.of(context).supportHeading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join the Ravencoin Discord for general Ravencoin discussions.',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'MOONTREE',
                    style: Theme.of(context).supportHeading,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join the Moontree Discord, where you can see frequently asked questions, find solutions and request help.',
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ]),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  actionButton(
                    context,
                    name: 'RAVENCOIN',
                    color: '0xFF4CAF50',
                  ),
                  SizedBox(width: 16),
                  actionButton(
                    context,
                    name: 'MOONTREE',
                    color: '0xFFFFB84D',
                    link: 'Jh9aqeuB3Q',
                  ),
                ]),
          ],
        ));
  }

  Widget actionButton(
    BuildContext context, {
    required String name,
    required String color,
    String? link,
  }) =>
      Container(
          width: (MediaQuery.of(context).size.width / 2) - 24,
          height: 40,
          child: OutlinedButton.icon(
            onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: Text('Open in External App'),
                        content: Text('Open discord app or browser?'),
                        actions: [
                          TextButton(
                              child: Text('Cancel'),
                              onPressed: () => Navigator.of(context).pop()),
                          TextButton(
                              child: Text('Continue'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                launch(
                                    'https://discord.gg/${link ?? name.toLowerCase()}');
                              })
                        ])),
            icon: Icon(MdiIcons.discord, color: Color(int.parse(color))),
            label: Text(name.toUpperCase()),
            style: components.styles.buttons.bottom(context),
          ));
}
