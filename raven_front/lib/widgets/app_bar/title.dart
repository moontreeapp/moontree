import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
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
  late String pageTitle = 'Wallet';
  late List listeners = [];
  final changeName = TextEditingController();

  @override
  void initState() {
    super.initState();
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
    if (pageTitle == 'Send') {
      return Text('', style: Theme.of(context).pageTitle);
    }
    if (pageTitle == 'Import_export') {
      return Text('Import / Export', style: Theme.of(context).pageTitle);
    }
    if (['Change', 'Remove', 'Verify'].contains(pageTitle)) {
      return Text('Security', style: Theme.of(context).pageTitle);
    }
    if (pageTitle == 'Transactions') {
      var symbol = streams.spend.form.value?.symbol ?? 'RVN';
      symbol = symbol == 'RVN' ? 'Ravencoin' : symbol;
      return Text(symbol, style: Theme.of(context).pageTitle);
    }
    if (pageTitle != 'Wallet' || accounts.data.length <= 1) {
      return Text(pageTitle, style: Theme.of(context).pageTitle);
    }
    return Text('Wallet', style: Theme.of(context).pageTitle);
    /* /// showing editable name of wallet account
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
    */
  }
}
