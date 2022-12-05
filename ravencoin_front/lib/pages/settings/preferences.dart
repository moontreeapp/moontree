import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';

class Preferences extends StatefulWidget {
  @override
  State createState() => new _PreferencesState();
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
            decoration: const InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'your name',
              hintText: 'Satoshi Nakamoto',
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
              title: const Text('Send immediately (without confirmation)'),
              value: pros.settings.primaryIndex
                  .getOne(SettingName.send_immediate)!
                  .value as bool,
              onChanged: (bool? value) async {
                await pros.settings.save(Setting(
                    name: SettingName.send_immediate,
                    value: !(pros.settings.primaryIndex
                        .getOne(SettingName.send_immediate)!
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

  Future alertSuccess() => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
            title: const Text('Success'),
            content: const Text('Preferences Saved!'),
            actions: [
              TextButton(
                  child: const Text('ok'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ));
}
