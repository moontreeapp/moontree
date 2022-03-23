import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:convert/convert.dart' as convert;
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_back/utilities/hex.dart' as hex;
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/services/storage.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class Export extends StatefulWidget {
  const Export() : super();

  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  final Backup storage = Backup();
  Wallet? wallet;
  File? file;
  List<Widget> getExisting = [];
  bool encryptExport = true;
  FocusNode previewFocus = FocusNode();
  TextEditingController walletController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    previewFocus.dispose();
    walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    wallet =
        walletController.text != '' && walletController.text != 'All Wallets'
            ? res.wallets.byName.getOne(walletController.text)
            : null;
    return body();
  }

  Widget body() => Padding(
      padding: EdgeInsets.only(left: 16.0, top: 16, right: 16, bottom: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          walletChoices,
          Row(children: [previewButton])
        ],
      ));

  Widget get walletChoices => TextField(
        controller: walletController,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Wallet',
          helperText: walletController.text == ''
              ? ''
              : 'A wallet password is recommended.',
          helperStyle: TextStyle(color: AppColors.error),
          suffixIcon: IconButton(
            icon: Padding(
                padding: EdgeInsets.only(right: 14),
                child:
                    Icon(Icons.expand_more_rounded, color: AppColors.black87)),
            onPressed: () => _produceWalletModal(),
          ),
        ),
        onTap: () {
          _produceWalletModal();
        },
        onEditingComplete: () async {
          FocusScope.of(context).requestFocus(previewFocus);
        },
      );

  Widget get previewButton => components.buttons.actionButton(
        context,
        enabled: walletController.text != '',
        focusNode: previewFocus,
        onPressed: () async {
          Navigator.of(components.navigator.routeContext!).pushNamed(
            '/settings/export/export',
            arguments: {
              'struct': CheckoutStruct(
                icon: Icon(Icons.account_balance_wallet_rounded,
                    size: 36, color: AppColors.primary),
                symbol: null,
                displaySymbol: walletController.text,
                subSymbol: null,
                paymentSymbol: null,
                left: .25,
                items: [
                  ['Location', await storage.localPath, '3'],
                  ['File', filePrefix + today + '.json', '2'],
                ],
                fees: null,
                total: null,
                confirm: 'Are you sure you want to export?',
                buttonAction: () => null,
                buttonWord: null,
                button: finalSubmitButtons,
                loadingMessage: 'Exporting',
              )
            },
          );
        },
      );

  Widget get finalSubmitButtons => Row(children: [
        components.buttons.actionButton(
          context,
          enabled: true,
          label: 'Share',
          onPressed: () async {
            await Share.share(rawExport);
          },
        ),
        SizedBox(width: 16),
        components.buttons.actionButton(
          context,
          enabled: true,
          label: 'Export',
          onPressed: () async {
            components.loading.screen(message: 'Exporting');
            file = await export();
            await Future.delayed(Duration(seconds: 1));
            streams.app.snack.add(Snack(
              message: 'Successfully Exported ${walletController.text}',
            ));
          },
        )
      ]);

  Future<File> export() async => await storage.writeExport(
        filename: filePrefix + today,
        rawExport: rawExport,
      );

  String get filePrefix => 'moontree_backup_';

  String get today =>
      DateTime.now().month.toString() +
      '_' +
      DateTime.now().day.toString() +
      '_' +
      DateTime.now().year.toString().substring(2);

  String get rawExport => services.password.required && encryptExport
      ? hex.encrypt(
          convert.hex.encode(
              jsonEncode(services.wallet.export.structureForExport())
                  .codeUnits),
          services.cipher.currentCipher!)
      : jsonEncode(services.wallet.export.structureForExport());

  void _produceWalletModal() async {
    await SelectionItems(context, modalSet: SelectionSet.Wallets)
        .build(controller: walletController);
    setState(() {/* to refresh and enable the button */});
  }
}
