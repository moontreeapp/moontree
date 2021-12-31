import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/streams.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/account.dart';
import 'package:raven_front/theme/extensions.dart';

class PageTitle extends StatefulWidget {
  PageTitle({Key? key}) : super(key: key);

  @override
  _PageTitleState createState() => _PageTitleState();
}

class _PageTitleState extends State<PageTitle> {
  String pageTitle = 'Wallet';
  List listeners = [];
  final changeName = TextEditingController();

  @override
  void initState() {
    super.initState();
    //listeners.add(ModalRoute.of(context)?.settings.name ??
    listeners.add(streams.app.page.stream.listen((value) {
      if (value != pageTitle) {
        setState(() {
          pageTitle = value;
        });
      }
    }));
  }

  @override
  void dispose() {
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pageTitle != 'Wallet' || accounts.data.length <= 1) {
      return Text(pageTitle, style: Theme.of(context).pageTitle);
    }
    changeName.text = 'Wallets / ' + Current.account.name;
    return TextField(
      textInputAction: TextInputAction.done,
      textAlign: TextAlign.left,
      style: Theme.of(context).pageTitle,
      decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none),
      controller: changeName,
      onTap: () {
        changeName.text = 'Wallets / ';
        changeName.selection = TextSelection.fromPosition(
            TextPosition(offset: changeName.text.length));
      },
      onSubmitted: (value) async {
        if (!await updateAcount(
            Current.account, value.replaceFirst('Wallets / ', ''))) {
          components.alerts.failure(context,
              headline: 'Unable rename account',
              msg: 'Account name, "$value" is already taken. '
                  'Please enter a uinque account name.');
        }
        setState(() {});
      },
    );
  }
}
