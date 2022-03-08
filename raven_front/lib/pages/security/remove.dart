import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class RemovePassword extends StatefulWidget {
  @override
  _RemovePasswordState createState() => _RemovePasswordState();
}

class _RemovePasswordState extends State<RemovePassword> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: streams.app.verify.value
            ? body()
            : VerifyPassword(parentState: this),
      );

  Widget body() {
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 16),
            Text('Are you sure?', style: Theme.of(context).textTheme.headline2),
            Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 40,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [submitButton()]))
          ],
        ));
  }

  Widget submitButton() {
    return Container(
        height: 40,
        child: OutlinedButton.icon(
            onPressed: () async => await submit(),
            icon: Icon(
              Icons.lock_rounded,
              color: Color(0x61000000),
            ),
            label: Text('Yes, Remove Password'.toUpperCase(),
                style: Theme.of(context).enabledButton),
            style: components.styles.buttons.bottom(context)));
  }

  Future submit() async {
    FocusScope.of(context).unfocus();
    streams.password.update.add('');
    Navigator.popUntil(
        components.navigator.routeContext!, ModalRoute.withName('/home'));
  }

  Future successMessage() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              title: Text('Success!'),
              content: Text('Password Removed!\n\n'
                  'Be careful out there!'),
              actions: [
                TextButton(
                    child:
                        Text('ok', style: Theme.of(context).sendConfirmButton),
                    onPressed: () {
                      Navigator.popUntil(context, ModalRoute.withName('/home'));
                    })
              ]));
}
