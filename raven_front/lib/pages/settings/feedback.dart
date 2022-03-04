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

class Feedback extends StatefulWidget {
  final dynamic data;
  const Feedback({this.data}) : super();

  @override
  _FeedbackState createState() => _FeedbackState();
}

class _FeedbackState extends State<Feedback> {
  dynamic data = {};
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
  void dispose() {
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  Widget body() => CustomScrollView(
        // solves scrolling while keyboard
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                greeting,
                typeField,
                descriptionField,
                emailField,
                if (file != null) filePicked,
              ],
            ),
          ),
          SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                  padding: EdgeInsets.only(
                      top: 16, left: 16.0, right: 16.0, bottom: 40),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Expanded(
                                  child:
                                      Container(height: 40, child: fileButton)),
                              SizedBox(width: 16),
                              Expanded(
                                  child: Container(
                                      height: 40, child: submitButton)),
                            ]),
                      ])))
        ],
      );

  Widget get greeting => Container(
        padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
        child: Text(
          'Let us know what you want changed, added or fixed!',
          style: Theme.of(context).feedbackGreeting,
        ),
      );

  Widget get typeField => Container(
        padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
        child: TextField(
          focusNode: typeFocus,
          controller: typeController,
          readOnly: true,
          decoration: components.styles.decorations.textFeild(context,
              labelText: 'Request Type',
              hintText: 'Request Type',
              suffixIcon: IconButton(
                icon: Padding(
                    padding: EdgeInsets.only(right: 14),
                    child: Icon(Icons.expand_more_rounded,
                        color: Color(0xDE000000))),
                onPressed: () => _produceFeedbackModal(),
              )),
          onTap: () => _produceFeedbackModal(),
          onEditingComplete: () =>
              FocusScope.of(context).requestFocus(descriptionFocus),
        ),
      );

  Widget get descriptionField => Container(
      height: 200,
      padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
      child: TextField(
        focusNode: descriptionFocus,
        autocorrect: false,
        controller: descriptionController,
        keyboardType: TextInputType.multiline,
        maxLines: 1000,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Description',
          hintText: 'As a user... I want... so that...',
          helperText: descriptionController.text == ''
              ? 'As a user... I want... so that...'
              : null,
          errorText: null,
        ),
        onChanged: (value) => enableSend(),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(emailFocus),
      ));

  Widget get emailField => Container(
      padding: EdgeInsets.only(top: 16, left: 16.0, right: 16.0),
      child: TextField(
        focusNode: emailFocus,
        autocorrect: false,
        controller: emailController,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Email Address',
          helperText: emailController.text == ''
              ? "We'll reach out to you if we have any questions"
              : null,
          errorText: null,
        ),
        onChanged: (value) => enableSend(),
        onEditingComplete: () async => await attemptSend(),
      ));

  Widget get filePicked => Column(children: [
        Divider(indent: 16, endIndent: 16),
        Padding(
            //padding: EdgeInsets.only(left: 8, top: 16.0),
            padding: EdgeInsets.only(left: 16, right: 0, top: 16, bottom: 0),
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.all(0),
              leading: Icon(Icons.attachment_rounded, color: Colors.black),
              title:
                  Text(file!.filename, style: Theme.of(context).importedFile),
              subtitle: Text('${file!.size.toString()} KB',
                  style: Theme.of(context).importedSize),
              trailing: IconButton(
                  icon: Icon(Icons.close_rounded, color: Color(0xDE000000)),
                  onPressed: () => setState(() => file = null)),
            )),
        Divider(),
      ]);

  Widget get submitButton {
    var label = 'Send'.toUpperCase();
    if (sendEnabled) {
      return OutlinedButton.icon(
          onPressed: () async =>
              await attemptSend(file?.content ?? descriptionController.text),
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

  Widget get fileButton => OutlinedButton.icon(
      icon: Icon(
        MdiIcons.fileKey,
        color: Color(0xDE000000),
      ),
      label: Text('FILE', style: Theme.of(context).enabledButton),
      onPressed: () async {
        file = await storage.readFromFilePickerSize();
        enableSend(file?.content ?? '');
        setState(() {});
      },
      style: components.styles.buttons.bottom(context));

  void enableSend([String? given]) {
    var oldsendEnabled = sendEnabled;
    sendEnabled = true; //validate all fields?

    if (oldsendEnabled != sendEnabled) {
      setState(() => {});
    }
  }

  Future attemptSend([String? importData]) async {
    FocusScope.of(context).unfocus();
    var text = (importData ?? descriptionController.text).trim();

    //streams.import.attempt.add(ImportRequest(text: text));
    components.loading.screen(message: 'Sending Feedback');
  }

  void _produceFeedbackModal() {
    SelectionItems(context, modalSet: SelectionSet.Feedback, behaviors: [
      () => setState(() => typeController.text = 'Change'),
      () => setState(() => typeController.text = 'Bug')
    ]).build();
  }
}
