import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';

class Advanced extends StatefulWidget {
  @override
  State createState() => new _AdvancedState();
}

//class Advanced extends StatelessWidget {
class _AdvancedState extends State<Advanced> {
  TextEditingController yourName = TextEditingController();
  bool termsAndConditions = false; // should be a setting along with others...

  @override
  Widget build(BuildContext context) {
    var name = res.settings.primaryIndex.getOne(SettingName.User_Name)?.value;
    if (name != null) {
      yourName.text = name;
    }
    return Scaffold(
      //appBar: components.headers.back(context, 'Advanced'),
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
              await res.settings.save(
                  Setting(name: SettingName.User_Name, value: yourName.text));
              alertSuccess();
            },
          ),
          SizedBox(height: 20),
          CheckboxListTile(
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.all(0),
              title: Text('Send immediately (without confirmation)'),
              value: res.settings.primaryIndex
                  .getOne(SettingName.Send_Immediate)!
                  .value,
              onChanged: (bool? value) async {
                await res.settings.save(Setting(
                    name: SettingName.Send_Immediate,
                    value: !res.settings.primaryIndex
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
            content: Text('Advanced Saved!'),
            actions: [
              TextButton(
                  child: Text('ok'),
                  onPressed: () => Navigator.of(context).pop())
            ],
          ));
}
