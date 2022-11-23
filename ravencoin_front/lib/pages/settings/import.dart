import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/streams/import.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/storage.dart';
import 'package:ravencoin_front/services/wallet.dart'
    show getEntropy, saveSecret;
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/utils/data.dart';
import 'package:ravencoin_front/widgets/other/selection_control.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class Import extends StatefulWidget {
  final dynamic data;
  const Import({this.data}) : super();

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  dynamic data = {};
  FocusNode wordsFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  TextEditingController words = TextEditingController();
  bool importEnabled = false;
  late Wallet wallet;
  String importFormatDetected = '';
  final Backup storage = Backup();
  final TextEditingController password = TextEditingController();
  FileDetails? file;
  String? finalText;
  String? finalAccountId;
  bool importVisible = true;
  bool submittedAttempt = false;

  @override
  void initState() {
    super.initState();
    //wordsFocus.addListener(_handleFocusChange);
  }

  //void _handleFocusChange() {
  //  setState(() {});
  //}

  @override
  void dispose() {
    //wordsFocus.removeListener(_handleFocusChange);
    words.dispose();
    wordsFocus.dispose();
    submitFocus.dispose();
    super.dispose();
  }

  Future<String> getClip() async {
    ClipboardData? clip = await Clipboard.getData('text/plain');
    if (clip != null) {
      return clip.text ?? '';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    data = populateData(context, data);
    if (data['walletId'] == 'current' || data['walletId'] == null) {
      wallet = Current.wallet;
    } else {
      wallet =
          pros.wallets.primaryIndex.getOne(data['walletId']) ?? Current.wallet;
    }
    return BackdropLayers(
        back: BlankBack(),
        front: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              enableImport();
            },
            child: FrontCurve(
              fuzzyTop: false,
              child: Platform.isIOS
                  ? body()
                  : FutureBuilder(
                      initialData: null,
                      future: getClip(),
                      builder: (context, snapshot) =>
                          body(snapshot.data as String?)),
            )));
  }

  Widget body([String? clip]) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          file == null ? textInputField(clip) : filePicked,
          components.containers.navBar(
            context,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: file == null
                    ? [
                        // hide file button
                        //if (!Platform.isIOS && words.text == '') fileButton,
                        //if (!Platform.isIOS && words.text == '')
                        //  SizedBox(width: 16),
                        submitButton(),
                      ]
                    : [submitButton('Import File')]),
          )
        ],
      );

  Widget textInputField([String? clip]) => Container(
      height: 200,
      padding: EdgeInsets.only(
        top: 16,
        left: 16.0,
        right: 16.0,
      ),
      child: TextFieldFormatted(
          focusNode: wordsFocus,
          selectionControls: CustomMaterialTextSelectionControls(
              context: components.navigator.scaffoldContext,
              offset: Offset(0, 20)),
          enableInteractiveSelection: true,
          autocorrect: false,
          controller: words,
          obscureText: !importVisible,
          keyboardType: TextInputType.multiline,
          maxLines: importVisible ? 12 : 1,
          textInputAction: TextInputAction.done,
          // interferes with voice - one word at a time:
          //inputFormatters: [LowerCaseTextFormatter()],
          labelText: wordsFocus.hasFocus ? 'Seed | WIF | Key' : null,
          hintText: 'Please enter seed words, a WIF, or a private key.',
          helperText:
              importFormatDetected == 'Unknown' ? null : importFormatDetected,
          errorText: submittedAttempt
              ? importFormatDetected == 'Unknown'
                  ? importFormatDetected
                  : null
              : null,
          suffixIcon:
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              icon: Icon(
                  importVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.black60),
              onPressed: () => setState(() {
                importVisible = !importVisible;
              }),
            ),
            if (clip != null && validateValue(clip))
              IconButton(
                  icon: Icon(Icons.paste_rounded, color: AppColors.black60),
                  onPressed: () => setState(() {
                        words.text = clip;
                        enableImport();
                      })),
            if (clip == null)
              IconButton(
                  icon: Icon(Icons.paste_rounded, color: AppColors.black60),
                  onPressed: () async {
                    final clip = await getClip();
                    setState(() {
                      words.text = clip;
                      enableImport();
                    });
                  }),
            IconButton(
                icon: Icon(Icons.clear_rounded,
                    color: words.text != ''
                        ? AppColors.black60
                        : AppColors.black12),
                onPressed: () => setState(() {
                      importFormatDetected = '';
                      words.text = '';
                    })),
          ]),
          onChanged: (value) {
            submittedAttempt = false;
            enableImport();
          },
          onEditingComplete: () {
            enableImport();
            FocusScope.of(context).requestFocus(submitFocus);
          }));

  Widget get filePicked => Column(children: [
        Padding(
            //padding: EdgeInsets.only(left: 8, top: 16.0),
            padding: EdgeInsets.only(left: 16, right: 0, top: 16, bottom: 0),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.attachment_rounded, color: Colors.black),
              title: Text(file!.filename,
                  style: Theme.of(context).textTheme.bodyText1),
              subtitle: Text('${file!.size.toString()} KB',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      height: 1,
                      fontWeight: FontWeights.semiBold,
                      color: AppColors.black38)),
              trailing: IconButton(
                  icon: Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => setState(() => file = null)),
            )),
        Divider(),
      ]);

  Widget submitButton([String? label]) =>
      components.buttons.actionButton(context,
          enabled: true, // importEnabled,
          focusNode: submitFocus,
          label: (label ?? 'Import').toUpperCase(),
          disabledIcon: components.icons.importDisabled(context),
          onPressed: () async {
        setState(() {
          submittedAttempt = true;
        });
        if (importEnabled) {
          await attemptImport(file?.content ?? words.text);
        } else {
          enableImport();
          if (importEnabled) {
            await attemptImport(file?.content ?? words.text);
          }
        }
      });

  Widget get fileButton => components.buttons.actionButton(
        context,
        label: 'File',
        onPressed: () async {
          file = await storage.readFromFilePickerSize();
          enableImport(given: file?.content ?? '');
          setState(() {});
        },
      );

  bool validateValue(String? given) =>
      services.wallet.import.detectImportType((given ?? words.text).trim()) !=
      ImportFormat.invalid;

  void enableImport({String? given}) {
    var oldImportFormatDetected = importFormatDetected;
    var detection =
        services.wallet.import.detectImportType((given ?? words.text).trim());
    importEnabled = detection != ImportFormat.invalid;
    if (detection == ImportFormat.mnemonic) {
      words.text = words.text.toLowerCase();
    }
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
        streams.app.scrim.add(true);
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
      }).then((value) => streams.app.scrim.add(false));

  Future attemptImport([String? importData]) async {
    FocusScope.of(context).unfocus();
    var text = (importData ?? words.text).trim();

    /* will fix decryption later
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
              builder: (BuildContext context) {
                streams.app.scrim.add(true);
                return AlertDialog(
                    title: Text('Password Not Recognized'),
                    content: Text(
                        'Password does not match the password used at the time of encryption.'));
              }).then((value) => streams.app.scrim.add(false));
          return;
        }
      }
      text = resp;
    }
    */

    /// save the key

    /// save the wallet
    components.loading.screen(
      message: 'Importing',
      staticImage: true,
      playCount: 2,
      then: () async => streams.import.attempt.add(ImportRequest(
        text: text,
        /*onSuccess: populateWalletsWithSensitives*/
        getEntropy: await getEntropy,
        saveSecret: await saveSecret,
      )),
    );
  }
}
