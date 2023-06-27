import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/import.dart';
import 'package:client_back/services/wallet/constants.dart';
import 'package:client_front/domain/utils/log.dart';
import 'package:client_front/infrastructure/services/storage.dart';
import 'package:client_front/infrastructure/services/wallet.dart'
    show getEntropy, saveSecret;
import 'package:client_front/application/app/import/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/other/selection_control.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
import 'package:client_front/presentation/components/components.dart'
    as components;

class ImportPage extends StatelessWidget {
  const ImportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Import();
}

class Import extends StatelessWidget {
  Import({Key? key}) : super(key: key);

  final FocusNode wordsFocus = FocusNode();
  final FocusNode submitFocus = FocusNode();
  final TextEditingController words = TextEditingController();
  final TextEditingController password = TextEditingController();
  final TextEditingController salt = TextEditingController();

  Future<String> getClip() async {
    if (Platform.isIOS) {
      return '';
    }
    final ClipboardData? clip = await Clipboard.getData('text/plain');
    if (clip != null) {
      return clip.text ?? '';
    }
    return '';
  }

  void focusSubmit(BuildContext context) async {
    FocusScope.of(context).requestFocus(submitFocus);
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
      future: getClip(),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) =>
          BlocBuilder<ImportFormCubit, ImportFormState>(
              builder: (context, state) {
            words.value = TextEditingValue(
                text: state.words,
                selection: words.selection.baseOffset > state.words.length
                    ? TextSelection.collapsed(offset: state.words.length)
                    : words.selection);
            return PageStructure(
                children: <Widget>[
                  if (state.file == null)
                    WordInput(
                      clip: snapshot.data,
                      state: state,
                      words: words,
                      wordsFocus: wordsFocus,
                    )
                  else
                    FilePicked(state: state),
                ],
                firstLowerChildren: state.file == null
                    ? <Widget>[
                        if (services.developer.advancedDeveloperMode &&
                            !Platform.isIOS &&
                            words.text == '')
                          FileButton(),
                        SubmitButton(state: state, submitFocus: submitFocus),
                      ]
                    : <Widget>[
                        SubmitButton(
                            label: 'Import File',
                            state: state,
                            submitFocus: submitFocus)
                      ]);
          }));
  //body(snapshot.data as String?)),

  Future<void> requestPassword(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) {
        streams.app.behavior.scrim.add(true);
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
      }).then((dynamic value) => streams.app.behavior.scrim.add(false));

  Future<void> requestSalt(BuildContext context) async => showDialog(
      context: context,
      builder: (BuildContext context) {
        streams.app.behavior.scrim.add(true);
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
      }).then((dynamic value) => streams.app.behavior.scrim.add(false));

  Future<void> attemptImport(BuildContext context, [String? importData]) async {
    FocusScope.of(context).unfocus();
    String text = (importData ?? words.text).trim();
    String resp = text;
    bool encrypted = true;
    Map<String, dynamic> textJson;

    if (components.cubits.import.state.detection == ImportFormat.json) {
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
            await requestPassword(context);
            await requestSalt(context);
            // cancelled
            if (password.text == '' && salt.text == '') {
              break;
            }
            components.cubits.loadingView
                .show(title: 'Decrypting', msg: 'one moment please');

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
            components.cubits.loadingView.hide();
            if (resp != text) {
              break;
            }
          }
          if (resp == text && encrypted) {
            showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      streams.app.behavior.scrim.add(true);
                      return const AlertDialog(
                          title: Text('Password Not Recognized'),
                          content: Text(
                              'Password does not match the password used at the time of encryption.'));
                    })
                .then((dynamic value) => streams.app.behavior.scrim.add(false));
            return;
          }
        }
        text = resp;
      }
    }
    await components.cubits.loadingView
        .show(title: 'Importing', msg: 'one moment please');
    await components.cubits.import.initiateImportProcess(ImportRequest(
      text: text,
      /*onSuccess: populateWalletsWithSensitives*/
      getEntropy: getEntropy,
      saveSecret: saveSecret,
    ));
    components.cubits.holdingsView.setHoldingViews(force: true);
    await Future.delayed(const Duration(milliseconds: 1330));
    components.cubits.loadingView.hide();
    components.cubits.import.reset();
    sail.home();
  }
}

class WordInput extends StatelessWidget {
  final String? clip;
  final ImportFormState state;
  final FocusNode wordsFocus;
  final TextEditingController words;

  const WordInput({
    super.key,
    required this.clip,
    required this.state,
    required this.wordsFocus,
    required this.words,
  });

  @override
  Widget build(BuildContext context) => Container(
      height: 200,
      child: TextFieldFormatted(
          focusNode: wordsFocus,
          selectionControls: CustomMaterialTextSelectionControls(
              context: components.routes.routeContext,
              offset: const Offset(0, 20)),
          autocorrect: false,
          controller: words,
          obscureText: !state.importVisible,
          keyboardType: TextInputType.multiline,
          maxLines: state.importVisible ? 12 : 1,
          textInputAction: TextInputAction.done,
          // interferes with voice - one word at a time:
          //inputFormatters: <TextInputFormatter>[LowerCaseTextFormatter()],
          labelText: wordsFocus.hasFocus ? 'Seed | WIF | Key' : null,
          hintText: 'Please enter seed words, a WIF, or a private key.',
          helperText: state.importFormatDetected == 'Unknown'
              ? state.words.split(' ').length == 12
                  ? 'unrecognized'
                  : null
              : state.importFormatDetected,
          errorText: state.submittedAttempt
              ? state.importFormatDetected == 'Unknown'
                  ? state.importFormatDetected
                  : null
              : null,
          suffixIcon: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                      state.importVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: AppColors.black60),
                  onPressed: () => components.cubits.import
                      .set(importVisible: !state.importVisible),
                ),
                //if (clip !=
                //    null /*&& components.cubits.import.validateValue(clip) we're just going to get it again anyway*/)
                //  IconButton(
                //      icon:
                //          const Icon(Icons.paste_rounded, color: AppColors.black60),
                //      onPressed: () async {
                //        final String clip = await (context
                //                .findAncestorWidgetOfExactType<Import>() as Import)
                //            .getClip();
                //        components.cubits.import.set(words: clip);
                //        components.cubits.import.enableImport();
                //      }),
                IconButton(
                    icon: Icon(Icons.clear_rounded,
                        color: words.text != ''
                            ? AppColors.black60
                            : AppColors.black12),
                    onPressed: () => components.cubits.import
                        .set(words: '', importFormatDetected: '')),
              ]),
          onChanged: (String value) {
            if (value.split(' ').length == 12) {
              components.cubits.import
                  .set(submittedAttempt: false, words: value);
              components.cubits.import.enableImport();
            }
          },
          onEditingComplete: () {
            components.cubits.import.enableImport();
            (context.findAncestorWidgetOfExactType<Import>() as Import)
                .focusSubmit(context);
          }));
}

class SubmitButton extends StatelessWidget {
  final FocusNode submitFocus;
  final String? label;
  final ImportFormState state;
  const SubmitButton({
    super.key,
    required this.submitFocus,
    required this.state,
    this.label,
  });

  @override
  Widget build(BuildContext context) => BottomButton(
      enabled: state.importEnabled,
      focusNode: submitFocus,
      label: (label ?? 'Import').toUpperCase(),
      //disabledIcon: components.icons.importDisabled(context),
      onPressed: () async {
        components.cubits.import.set(submittedAttempt: true);
        if (state.importEnabled) {
          await (context.findAncestorWidgetOfExactType<Import>() as Import)
              .attemptImport(
                  context,
                  components.cubits.import.state.file?.content ??
                      components.cubits.import.state.words);
        } else {
          components.cubits.import.enableImport();
          if (components.cubits.import.state.importEnabled) {
            await (context.findAncestorWidgetOfExactType<Import>() as Import)
                .attemptImport(
                    context,
                    components.cubits.import.state.file?.content ??
                        components.cubits.import.state.words);
          }
        }
      });
}

class FilePicked extends StatelessWidget {
  final ImportFormState state;
  const FilePicked({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) => Column(children: <Widget>[
        Padding(
            //padding: const EdgeInsets.only(left: 8, top: 16.0),
            padding: const EdgeInsets.only(left: 16, top: 16),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.attachment_rounded, color: Colors.black),
              title: Text(state.file!.filename,
                  style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text('${state.file!.size.toString()} KB',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      height: 1,
                      fontWeight: FontWeights.semiBold,
                      color: AppColors.black38)),
              trailing: IconButton(
                  icon:
                      const Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => components.cubits.import.set(file: null)),
            )),
        const Divider(),
      ]);
}

class FileButton extends StatelessWidget {
  const FileButton({super.key});

  @override
  Widget build(BuildContext context) => BottomButton(
        label: 'File',
        onPressed: () async {
          components.cubits.import
              .set(file: await Backup().readFromFilePickerSize());
          components.cubits.import.enableImport(
              given: components.cubits.import.state.file?.content ?? '');
        },
      );
}
