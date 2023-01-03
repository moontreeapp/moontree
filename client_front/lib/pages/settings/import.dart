import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/import.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_back/streams/import.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/services/lookup.dart';
import 'package:client_front/services/storage.dart';
import 'package:client_front/services/wallet.dart' show getEntropy, saveSecret;
import 'package:client_front/theme/theme.dart';
import 'package:client_front/utils/data.dart';
import 'package:client_front/widgets/other/selection_control.dart';
import 'package:client_front/widgets/widgets.dart';

import '../../utils/log.dart';

class Import extends StatefulWidget {
  final dynamic data;
  const Import({Key? key, this.data}) : super(key: key);

  @override
  _ImportState createState() => _ImportState();
}

class _ImportState extends State<Import> {
  Map<String, dynamic> data = <String, dynamic>{};
  FocusNode wordsFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  TextEditingController words = TextEditingController();
  bool importEnabled = false;
  late Wallet wallet;
  String importFormatDetected = '';
  final Backup storage = Backup();
  final TextEditingController password = TextEditingController();
  final TextEditingController salt = TextEditingController();
  FileDetails? file;
  String? finalText;
  String? finalAccountId;
  bool importVisible = true;
  bool submittedAttempt = false;
  ImportFormat detection = ImportFormat.invalid;

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
    final ClipboardData? clip = await Clipboard.getData('text/plain');
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
      wallet = pros.wallets.primaryIndex.getOne(data['walletId'] as String?) ??
          Current.wallet;
    }
    return BackdropLayers(
        back: const BlankBack(),
        front: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              enableImport();
            },
            child: FrontCurve(
              fuzzyTop: false,
              child: Platform.isIOS
                  ? body()
                  : FutureBuilder<String>(
                      future: getClip(),
                      builder: (BuildContext context,
                              AsyncSnapshot<Object?> snapshot) =>
                          body(snapshot.data as String?)),
            )));
  }

  Widget body([String? clip]) => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          if (file == null) textInputField(clip) else filePicked,
          components.containers.navBar(
            context,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: file == null
                    ? <Widget>[
                        if (services.developer.advancedDeveloperMode &&
                            !Platform.isIOS &&
                            words.text == '') ...<Widget>[
                          fileButton,
                          const SizedBox(width: 16)
                        ],
                        submitButton(),
                      ]
                    : <Widget>[submitButton('Import File')]),
          )
        ],
      );

  Widget textInputField([String? clip]) => Container(
      height: 200,
      padding: const EdgeInsets.only(
        top: 16,
        left: 16.0,
        right: 16.0,
      ),
      child: TextFieldFormatted(
          focusNode: wordsFocus,
          selectionControls: CustomMaterialTextSelectionControls(
              context: components.navigator.scaffoldContext,
              offset: const Offset(0, 20)),
          autocorrect: false,
          controller: words,
          obscureText: !importVisible,
          keyboardType: TextInputType.multiline,
          maxLines: importVisible ? 12 : 1,
          textInputAction: TextInputAction.done,
          // interferes with voice - one word at a time:
          //inputFormatters: <TextInputFormatter>[LowerCaseTextFormatter()],
          labelText: wordsFocus.hasFocus ? 'Seed | WIF | Key' : null,
          hintText: 'Please enter seed words, a WIF, or a private key.',
          helperText:
              importFormatDetected == 'Unknown' ? null : importFormatDetected,
          errorText: submittedAttempt
              ? importFormatDetected == 'Unknown'
                  ? importFormatDetected
                  : null
              : null,
          suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                      icon: const Icon(Icons.paste_rounded,
                          color: AppColors.black60),
                      onPressed: () => setState(() {
                            words.text = clip;
                            enableImport();
                          })),
                if (clip == null)
                  IconButton(
                      icon: const Icon(Icons.paste_rounded,
                          color: AppColors.black60),
                      onPressed: () async {
                        final String clip = await getClip();
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
          onChanged: (String value) {
            submittedAttempt = false;
            enableImport();
          },
          onEditingComplete: () {
            enableImport();
            FocusScope.of(context).requestFocus(submitFocus);
          }));

  Widget get filePicked => Column(children: <Widget>[
        Padding(
            //padding: const EdgeInsets.only(left: 8, top: 16.0),
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.attachment_rounded, color: Colors.black),
              title: Text(file!.filename,
                  style: Theme.of(context).textTheme.bodyText1),
              subtitle: Text('${file!.size.toString()} KB',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      height: 1,
                      fontWeight: FontWeights.semiBold,
                      color: AppColors.black38)),
              trailing: IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => setState(() => file = null)),
            )),
        const Divider(),
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
    final String oldImportFormatDetected = importFormatDetected;
    detection =
        services.wallet.import.detectImportType((given ?? words.text).trim());
    importEnabled = detection != ImportFormat.invalid;
    if (detection == ImportFormat.mnemonic) {
      words.text = words.text.toLowerCase();
    }
    if (importEnabled) {
      importFormatDetected =
          'format recognized as ${detection.toString().split('.')[1]}';
    } else {
      importFormatDetected = '';
    }
    if (detection == ImportFormat.invalid) {
      importFormatDetected = 'Unknown';
    }
    if (oldImportFormatDetected != importFormatDetected) {
      setState(() {});
    }
  }

  Future<void> requestPassword() async => showDialog(
      context: context,
      builder: (BuildContext context) {
        streams.app.scrim.add(true);
        return AlertDialog(
          title: Column(
            children: <Widget>[
              TextFieldFormatted(
                  autocorrect: false,
                  controller: password,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  labelText: 'Password',
                  hintText: 'Password123!',
                  helperText:
                      'leave blank if you used biometric or native authentication when creating the export.',
                  helperMaxLines: 10,
                  onEditingComplete: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Next'))
            ],
          ),
        );
      }).then((dynamic value) => streams.app.scrim.add(false));

  Future<void> requestSalt() async => showDialog(
      context: context,
      builder: (BuildContext context) {
        streams.app.scrim.add(true);
        return AlertDialog(
          title: Column(
            children: <Widget>[
              TextFieldFormatted(
                  autocorrect: false,
                  controller: salt,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  hintText: 'Encryption Key',
                  helperText:
                      'This key was provided when the export was created.',
                  helperMaxLines: 10,
                  onEditingComplete: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit'))
            ],
          ),
        );
      }).then((dynamic value) => streams.app.scrim.add(false));

  Future<void> attemptImport([String? importData]) async {
    FocusScope.of(context).unfocus();
    String text = (importData ?? words.text).trim();
    String resp = text;
    bool encrypted = true;
    Map<String, dynamic> textJson;

    if (detection == ImportFormat.json) {
      /// decrypt if you must...
      if (importData != null) {
        try {
          textJson = json.decode(text) as Map<String, dynamic>;
        } catch (e) {
          textJson = <String, dynamic>{};
        }
        if (textJson.isNotEmpty) {
          try {
            final Map<String, dynamic> wallets =
                textJson['wallets']! as Map<String, dynamic>;
            for (final dynamic walletJson in wallets.values) {
              final String decrypted = ImportFrom.maybeDecrypt(
                text: (walletJson as Map<String, dynamic>)['secret'] as String,
                cipher: services.cipher.currentCipher!,
              );
              resp =
                  resp.replaceFirst(walletJson['secret'] as String, decrypted);
            }
          } catch (e) {
            //log(e);
          }
        }
        if (resp == text) {
          // ask for password, make cipher, pass that cipher in.
          // what if it's not the latest cipher type? just try all cipher types...
          for (final CipherType cipherType in services.cipher.allCipherTypes) {
            await requestPassword();
            await requestSalt();
            // cancelled
            if (password.text == '' && salt.text == '') {
              break;
            }
            await components.loading.screen(
              message: 'Decrypting',
              staticImage: true,
              playCount: 2,
            );
            try {
              final Map<String, dynamic> wallets =
                  textJson['wallets']! as Map<String, dynamic>;
              for (final dynamic walletJson in wallets.values) {
                if (((walletJson as Map<String, dynamic>)['secret'] as String)
                        .split(' ')
                        .length ==
                    12) {
                  encrypted = false;
                  break;
                }
                final String decrypted = ImportFrom.maybeDecrypt(
                  text: walletJson['secret'] as String,
                  cipher: CipherProclaim.cipherInitializers[cipherType]!(
                      services.cipher.getPassword(
                          altPassword:
                              password.text == '' ? salt.text : password.text),
                      services.cipher.getSalt(
                          altSalt: salt.text == ''
                              ? password.text
                              : salt.text)) as CipherBase,
                );
                resp = resp.replaceFirst(
                    walletJson['secret'] as String, decrypted);
              }
            } catch (e) {
              log(e);
            }
            if (resp != text) {
              break;
            }
          }
          if (resp == text && encrypted) {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  streams.app.scrim.add(true);
                  return const AlertDialog(
                      title: Text('Password Not Recognized'),
                      content: Text(
                          'Password does not match the password used at the time of encryption.'));
                }).then((dynamic value) => streams.app.scrim.add(false));
            return;
          }
        }
        text = resp;
      }
    }
    /* will fix decryption later
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
        getEntropy: getEntropy,
        saveSecret: saveSecret,
      )),
    );
  }
}
