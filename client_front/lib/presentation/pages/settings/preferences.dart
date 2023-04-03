import 'package:flutter/material.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:client_back/client_back.dart';

class Preferences extends StatefulWidget {
  const Preferences({Key? key}) : super(key: key);

  @override
  State createState() => _PreferencesState();
}

//class Preferences extends StatelessWidget {
class _PreferencesState extends State<Preferences> {
  TextEditingController yourName = TextEditingController();
  bool termsAndConditions = false; // should be a setting along with others...

  @override
  Widget build(BuildContext context) {
    final String? name = pros.settings.primaryIndex
        .getOne(SettingName.user_name)
        ?.value as String?;
    if (name != null) {
      yourName.text = name;
    }
    return Scaffold(
      //appBar: components.headers.back(context, 'Preferences'),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          const SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: yourName,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'your name',
              hintText: ['Satoshi', 'Tron', 'Jane', 'Anonymous'].randomChoice +
                  ['Nakamoto', 'Black', 'Doe', 'Hampster'].randomChoice,
            ),
            onEditingComplete: () async {
              await pros.settings.save(
                  Setting(name: SettingName.user_name, value: yourName.text));
              alertSuccess();
            },
          ),
          const SizedBox(height: 20),
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('Hide fee only transactions in history'),
              value: pros.settings.primaryIndex
                  .getOne(SettingName.hide_fees)!
                  .value as bool,
              onChanged: (bool? value) async {
                await pros.settings.save(Setting(
                    name: SettingName.hide_fees,
                    value: !(pros.settings.primaryIndex
                        .getOne(SettingName.hide_fees)!
                        .value as bool)));
                setState(() {});
              }),
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('I agree to the Terms and Conditions'),
              value: termsAndConditions,
              onChanged: (bool? value) => setState(() {
                    termsAndConditions = value ?? false;
                  })),
          //Text('Send immediately (without confirmation)')
        ],
      ),
    );
  }

  Future<void> alertSuccess() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Preferences Saved!'),
            actions: <Widget>[
              TextButton(
                  child: const Text('ok'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ));
}
