import 'dart:async';

import 'package:flutter/material.dart';
import 'package:client_front/components/components.dart';
import 'package:client_front/services/storage.dart';
import 'package:client_front/theme/theme.dart';
import 'package:client_front/widgets/widgets.dart';

class Feedback extends StatefulWidget {
  const Feedback({Key? key, this.data}) : super(key: key);
  final dynamic data;

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  dynamic data = <dynamic, dynamic>{};
  final TextEditingController typeController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final FocusNode typeFocus = FocusNode();
  final FocusNode descriptionFocus = FocusNode();
  final FocusNode emailFocus = FocusNode();
  final Backup storage = Backup();
  FileDetails? file;
  bool sendEnabled = false;

  @override
  void initState() {
    super.initState();
    descriptionFocus.addListener(_handleFocusChange);
    emailFocus.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    setState(() {});
  }

  @override
  void dispose() {
    descriptionFocus.removeListener(_handleFocusChange);
    emailFocus.removeListener(_handleFocusChange);
    descriptionFocus.dispose();
    emailFocus.dispose();
    typeController.dispose();
    descriptionController.dispose();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //file = FileDetails(
    //  filename: 'file.name',
    //  content: 'asdf',
    //  size: 2.3,
    //);
    return BackdropLayers(
        back: const BlankBack(),
        front: FrontCurve(
            child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: body(),
        )));
  }

  Widget body() => components.page.form(
        context,
        columnWidgets: <Widget>[
          greeting,
          typeField,
          descriptionField,
          emailField,
          if (file != null) filePicked,
        ],
        buttons: <Widget>[fileButton, submitButton],
      );

  Widget get greeting => Text(
        'Let us know what you want changed, added or fixed!',
        style: Theme.of(context).textTheme.bodyText1,
      );

  Widget get typeField => TextFieldFormatted(
        focusNode: typeFocus,
        controller: typeController,
        readOnly: true,
        labelText: 'Request Type',
        hintText: 'Request Type',
        suffixIcon: IconButton(
          icon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
          onPressed: () => _produceFeedbackModal(),
        ),
        onTap: () => _produceFeedbackModal(),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(descriptionFocus),
      );

  Widget get descriptionField => SizedBox(
      height: 200,
      child: TextFieldFormatted(
          focusNode: descriptionFocus,
          autocorrect: false,
          controller: descriptionController,
          keyboardType: TextInputType.multiline,
          maxLines: 1000,
          textInputAction: TextInputAction.done,
          style: descriptionFocus.hasFocus
              ? Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: AppColors.offBlack)
              : Theme.of(context).textTheme.subtitle1,
          labelText: 'Description',
          hintText: 'As a user... I want... so that...',
          helperText: descriptionController.text == ''
              ? 'As a user... I want... so that...'
              : null,
          onChanged: (String value) => enableSend(),
          onEditingComplete: () {
            print(descriptionFocus.hasFocus);
            FocusScope.of(context).requestFocus(emailFocus);
            setState(() {});
          }));

  Widget get emailField => TextFieldFormatted(
        focusNode: emailFocus,
        autocorrect: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        style: emailFocus.hasFocus
            ? Theme.of(context)
                .textTheme
                .subtitle1!
                .copyWith(color: AppColors.offBlack)
            : Theme.of(context).textTheme.subtitle1,
        labelText: 'Email Address',
        helperText: emailController.text == ''
            ? "We'll reach out to you if we have any questions"
            : null,
        onChanged: (String value) => enableSend(),
        onEditingComplete: () async => attemptSend(),
      );

  Widget get filePicked => Column(children: <Widget>[
        const Divider(indent: 0, endIndent: 0),
        Padding(
            padding: const EdgeInsets.only(left: 0, top: 16),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.attachment_rounded, color: Colors.black),
              title: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(file!.filename,
                      style: Theme.of(context).textTheme.bodyText1)),
              subtitle: Text('${file!.size.toString()} KB',
                  style: Theme.of(context).textTheme.bodyText2!.copyWith(
                      height: 1,
                      fontWeight: FontWeights.semiBold,
                      color: AppColors.black38)),
              trailing: IconButton(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.zero,
                  icon:
                      const Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => setState(() => file = null)),
            )),
        const Divider(),
      ]);

  Widget get submitButton => components.buttons.actionButton(context,
      enabled: sendEnabled,
      label: 'Send'.toUpperCase(),
      onPressed: () async =>
          attemptSend(file?.content ?? descriptionController.text),
      disabledIcon: components.icons.importDisabled(context));

  Widget get fileButton => components.buttons.actionButton(
        context,
        label: 'File',
        onPressed: () async {
          file = await storage.readFromFilePickerSize();
          enableSend(file?.content ?? '');
          setState(() {});
        },
      );

  void enableSend([String? given]) {
    final bool oldsendEnabled = sendEnabled;
    sendEnabled = true; //validate all fields?

    if (oldsendEnabled != sendEnabled) {
      setState(() {});
    }
  }

  Future<void> attemptSend([String? importData]) async {
    FocusScope.of(context).unfocus();
    //var text = (importData ?? descriptionController.text).trim();
    //streams.feeback.send.add(ImportRequest(text: text)); // not real
    components.loading.screen(message: 'Sending Feedback');
  }

  void _produceFeedbackModal() {
    SelectionItems(context,
        modalSet: SelectionSet.Feedback,
        behaviors: <void Function()>[
          () => setState(() => typeController.text = 'Change'),
          () => setState(() => typeController.text = 'Bug')
        ]).build();
  }
}
