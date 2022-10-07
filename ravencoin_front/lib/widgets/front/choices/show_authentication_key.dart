import 'package:flutter/material.dart';

import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart';

class ShowAuthenticationChoice extends StatefulWidget {
  final dynamic data;
  const ShowAuthenticationChoice({this.data}) : super();

  @override
  _ShowAuthenticationChoice createState() => _ShowAuthenticationChoice();
}

class _ShowAuthenticationChoice extends State<ShowAuthenticationChoice> {
  bool show = false;
  String msg = 'Show';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text('Show Authentication Key',
            style: Theme.of(context).textTheme.bodyText1),
        Text(
          'Default and password if you use native authentication.',
          style: Theme.of(context).textTheme.bodyText2,
        ),
        SizedBox(height: 16),
        Row(
          children: [
            components.buttons.actionButton(
              context,
              enabled: true,
              label: '$msg Key',
              onPressed: () => setState(() {
                show = !show;
                msg = msg == 'Show' ? 'Hide' : 'Show';
              }),
            ),
          ],
        ),
        SizedBox(height: 16),
        if (show)
          FutureBuilder<String>(
              future: SecureStorage.authenticationKey,
              builder: (context, AsyncSnapshot<String> snapshot) {
                if (snapshot.hasData) {
                  return Text(snapshot.data!);
                }
                return Container();
              })
      ],
    );
  }
}
