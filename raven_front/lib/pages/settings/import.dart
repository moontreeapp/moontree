import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/wallet/constants.dart';
import 'package:raven_back/streams/import.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:raven_back/services/import.dart';

class Import extends StatefulWidget {
  final dynamic data;
  const Import({this.data}) : super();

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  dynamic data = {};
  var words = TextEditingController();
  bool importEnabled = false;
  late Wallet wallet;
  String importFormatDetected = '';
  final Backup storage = Backup();
  final TextEditingController password = TextEditingController();
  FileDetails? file;
  String? finalText;
  String? finalAccountId;

  @override
  void dispose() {
    words.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['walletId'] == 'current' || data['walletId'] == null) {
      wallet = Current.wallet;
    } else {
      wallet =
          res.wallets.primaryIndex.getOne(data['walletId']) ?? Current.wallet;
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  Widget submitButton() {
    var label = 'IMPORT';
    if (importEnabled) {
      return OutlinedButton.icon(
          onPressed: () async =>
              await attemptImport(file?.content ?? words.text),
          icon: components.icons.import,
          label: Text(label, style: Theme.of(context).enabledButton),
          style: components.styles.buttons.bottom(context));
    }
    return OutlinedButton.icon(
        onPressed: () {},
        icon: components.icons.importDisabled(context),
        label: Text(label, style: Theme.of(context).disabledButton),
        style: components.styles.buttons.bottom(context, disabled: true));
  }

  void enableImport([String? given]) {
    var oldImportFormatDetected = importFormatDetected;
    var detection =
        services.wallet.import.detectImportType((given ?? words.text).trim());
    importEnabled = detection != null && detection != ImportFormat.invalid;

    if (importEnabled) {
      importFormatDetected =
          'format recognized as ' + detection.toString().split('.')[1];
    } else {
      importFormatDetected = '';
    }
    if (detection == ImportFormat.invalid) {
      importFormatDetected = 'Unknown';
    }
    if (oldImportFormatDetected != importFormatDetected) {
      setState(() => {});
    }
  }

  Future requestPassword() async => showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Column(
            children: <Widget>[
              TextField(
                  autocorrect: false,
                  controller: password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    hintText: 'password',
                  ),
                  onEditingComplete: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Submit'))
            ],
          ),
        );
      });

  Future attemptImport([String? importData]) async {
    FocusScope.of(context).unfocus();
    var text = (importData ?? words.text).trim();

    /// decrypt if you must...
    if (importData != null) {
      var resp;
      try {
        resp = ImportFrom.maybeDecrypt(
          text: importData,
          cipher: services.cipher.currentCipher!,
        );
      } catch (e) {}
      if (resp == null) {
        // ask for password, make cipher, pass that cipher in.
        // what if it's not the latest cipher type? just try all cipher types...
        for (var cipherType in services.cipher.allCipherTypes) {
          await requestPassword();
          // cancelled
          if (password.text == '') break;
          try {
            resp = ImportFrom.maybeDecrypt(
                text: importData,
                cipher: CipherReservoir.cipherInitializers[cipherType]!(
                    services.cipher.getPassword(altPassword: password.text)));
          } catch (e) {}
          if (resp != null) break;
        }
        if (resp == null) {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                  title: Text('Password Not Recognized'),
                  content: Text(
                      'Password does not match the password used at the time of encryption.')));
          return;
        }
      }
      text = resp;
    }
    streams.import.attempt.add(ImportRequest(text: text));
    components.loading.screen(message: 'Importing');
  }

  Widget body() => Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  height: 200,
                  child: TextField(
                    autocorrect: false,
                    controller: words,
                    keyboardType: TextInputType.multiline,
                    maxLines: 12,
                    textInputAction: TextInputAction.done,
                    decoration: components.styles.decorations.textFeild(
                      context,
                      labelText: 'Seed, WIF, or Key',
                      hintText:
                          'Please enter your seed words, WIF, or private key',
                      helperText: importFormatDetected == 'Unknown'
                          ? null
                          : importFormatDetected,
                      errorText: importFormatDetected == 'Unknown'
                          ? importFormatDetected
                          : null,
                    ),
                    onChanged: (value) => enableImport(),
                    onEditingComplete: () async => await attemptImport(),
                  )),
              SizedBox(height: 16),
              importWaysButtons(),
            ],
          ),
          Padding(
              padding: EdgeInsets.only(
                top: 0,
                bottom: 40,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [Container(height: 40, child: submitButton())]))
        ],
      ));

  Widget importWaysButtons() => file != null
      ? Container(
          height: 72,
          decoration: BoxDecoration(
              color: Color(0x1F5C6BC0),
              borderRadius: BorderRadius.all(Radius.circular(8.0))),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                SizedBox(width: 18),
                Icon(Icons.attachment_rounded),
                SizedBox(width: 18),
                Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(file!.filename,
                          style: Theme.of(context).importedFile),
                      Text('${file!.size.toString()} KB',
                          style: Theme.of(context).importedSize),
                    ]),
              ]),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                IconButton(
                    icon: Icon(Icons.close_rounded),
                    onPressed: () => setState(() => file = null)),
                SizedBox(width: 13),
              ])
            ],
          ))
      : TextButton.icon(
          icon: Icon(
            MdiIcons.fileKey,
            color: Theme.of(context).backgroundColor,
          ),
          label: Text('IMPORT FILE', style: Theme.of(context).textButton),
          onPressed: () async {
            file = await storage.readFromFilePickerSize();
            enableImport(file?.content ?? '');
            setState(() {});
            //var resp = await storage.readFromFilePickerRaw() ?? '';
            //await attemptImport(resp);
          },
          //style: components.styles.buttons.curvedSides
        );
}
