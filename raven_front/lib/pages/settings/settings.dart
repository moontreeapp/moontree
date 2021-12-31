import 'package:flutter/material.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_back/raven_back.dart';

class Settings extends StatefulWidget {
  @override
  State createState() => new _SettingsState();
}

//class Settings extends StatelessWidget {
class _SettingsState extends State<Settings> {
  TextEditingController yourName = TextEditingController();
  bool termsAndConditions = false; // should be a setting along with others...

  @override
  Widget build(BuildContext context) {
    var name = settings.primaryIndex.getOne(SettingName.User_Name)?.value;
    if (name != null) {
      yourName.text = name;
    }
    return Scaffold(
      //appBar: components.headers.back(context, 'Settings'),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          SizedBox(height: 20),
          TextField(
            autocorrect: false,
            controller: yourName,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              border: UnderlineInputBorder(),
              labelText: 'your name',
              hintText: 'Satoshi Nakamoto',
            ),
            onEditingComplete: () async {
              await settings.save(
                  Setting(name: SettingName.User_Name, value: yourName.text));
              alertSuccess();
            },
          ),
          SizedBox(height: 20),
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              title: Text('Send immediately (without confirmation)'),
              value: settings.primaryIndex
                  .getOne(SettingName.Send_Immediate)!
                  .value,
              onChanged: (bool? value) async {
                await settings.save(Setting(
                    name: SettingName.Send_Immediate,
                    value: !settings.primaryIndex
                        .getOne(SettingName.Send_Immediate)!
                        .value));
                setState(() {});
              }),
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              title: Text('I agree to the Terms and Conditions'),
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
            title: Text('Success'),
            content: Text('Settings Saved!'),
            actions: [
              TextButton(
                  child: Text('ok'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ));
}
