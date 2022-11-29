import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/storage.dart';

class ShowAuthenticationChoice extends StatefulWidget {
  final String? title;
  final String? desc;
  const ShowAuthenticationChoice({
    this.title = 'Show Authentication Key',
    this.desc = 'Default and password if you use native authentication.',
  }) : super();

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
        if (widget.title != null)
          Text(widget.title!, style: Theme.of(context).textTheme.bodyText1),
        if (widget.desc != null)
          Text(
            widget.desc!,
            style: Theme.of(context).textTheme.bodyText2,
          ),
        SizedBox(height: 16),
        Row(
          children: [
            components.buttons.actionButtonSoft(
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
                  return SelectableText(snapshot.data!);
                }
                return Container();
              })
      ],
    );
  }
}
