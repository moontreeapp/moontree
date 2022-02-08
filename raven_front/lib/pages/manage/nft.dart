import 'package:flutter/material.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/widgets/widgets.dart';

class NFTCreate extends StatefulWidget {
  @override
  _NFTCreateState createState() => _NFTCreateState();
}

class _NFTCreateState extends State<NFTCreate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode ipfsFocusNode = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    ipfsController.dispose();
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
    var newPasswordField = TextField(
      focusNode: nameFocusNode,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'NFT Name',
        hintText: 'NFT Name',
        helperText: nameValidated ? 'something' : null,
        errorText: !nameValidated ? 'err' : null,
      ),
      onChanged: (String value) => validateName(name: value),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(ipfsFocusNode),
    );
    var confirmPasswordField = TextField(
      focusNode: ipfsFocusNode,
      autocorrect: false,
      controller: ipfsController,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'IPFS/TX id',
        hintText: 'IPFS/TX id',
        helperText: ipfsValidated ? 'match' : null,
        errorText: !ipfsValidated ? 'error' : null,
      ),
      onChanged: (String value) => validateIPFS(ipfs: value),
      onEditingComplete: () async => await submit(),
    );
    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  newPasswordField,
                  SizedBox(height: 16),
                  confirmPasswordField
                ]),
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
    var enabled = nameValidated && ipfsValidated;
    return Container(
        height: 40,
        child: OutlinedButton.icon(
            onPressed: enabled ? () async => await submit() : () {},
            icon: Icon(
              Icons.lock_rounded,
              color: enabled ? null : Color(0x61000000),
            ),
            label: Text(
              'Set'.toUpperCase(),
              style: enabled
                  ? Theme.of(context).enabledButton
                  : Theme.of(context).disabledButton,
            ),
            style: components.styles.buttons.bottom(
              context,
              disabled: !enabled,
            )));
  }

  bool nameValidation(String name) => name != '' && name.length < 28;

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs != '' && ipfs.length < 28;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated) {
      setState(() => {});
    }
  }

  Future submit() async {
    if (nameValidation(nameController.text) &&
        ipfsValidation(ipfsController.text)) {
      FocusScope.of(context).unfocus();

      /// create TX by passing the details to a stream (see send page)
      //streams.password.update.add(newPassword.text);

      /// send to transaction confirmation screen

    }
  }
}
