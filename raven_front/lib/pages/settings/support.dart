import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_front/components/components.dart';

class Support extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BackdropLayers(
      back: BlankBack(),
      front: FrontCurve(
        child: Padding(
            padding: EdgeInsets.only(top: 16),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  //SizedBox(height: 40),
                  Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Ravencoin',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        SizedBox(height: 8),
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Join the Ravencoin Discord for general Ravencoin discussions.',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        SizedBox(height: 16),
                        Divider(indent: 0),
                        SizedBox(height: 16),
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Moontree',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                        SizedBox(height: 8),
                        Padding(
                            padding: EdgeInsets.only(left: 16, right: 16),
                            child: Text(
                              'Join the Moontree Discord, where you can see frequently asked questions, find solutions and request help.',
                              style: Theme.of(context).textTheme.bodyText1,
                            )),
                      ]),
                  components.containers.navBar(context,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            actionButton(
                              context,
                              name: 'RAVENCOIN',
                            ),
                            SizedBox(width: 16),
                            actionButton(
                              context,
                              name: 'MOONTREE',
                              link: 'Jh9aqeuB3Q',
                            ),
                          ])),
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
      );
}
