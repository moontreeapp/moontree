import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:share/share.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/services/storage.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class Export extends StatefulWidget {
  const Export({Key? key}) : super(key: key);

  @override
  _ExportState createState() => _ExportState();
}

class _ExportState extends State<Export> {
  final Backup storage = Backup();
  Iterable<Wallet>? wallets;
  File? file;
  List<Widget> getExisting = <Widget>[];
  FocusNode previewFocus = FocusNode();
  TextEditingController walletController = TextEditingController();

  @override
  void initState() {
    super.initState();
    streams.app.verify.add(false);
  }

  @override
  void dispose() {
    previewFocus.dispose();
    walletController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (pros.wallets.length == 1) {
      wallets = pros.wallets;
    } else {
      wallets = walletController.text.isEmpty
          ? null
          : (walletController.text != 'All Wallets'
              ? () {
                  final Wallet? maybeWallet = pros.wallets.byName
                      // ravencoin_front/lib/widgets/bottom/selection_items.dart
                      // L315
                      .getOne(
                          walletController.text.replaceFirst('Wallet ', ''));
                  if (maybeWallet != null) {
                    return <Wallet>{maybeWallet};
                  }
                  return null;
                }()
              : pros.wallets);
    }
    if (wallets?.length == 1) {
      walletController.text = 'Wallet ${wallets?.first.name}';
    }
    return services.password.askCondition
        ? VerifyAuthentication(
            parentState: this, buttonLabel: 'Proceed to Export')
        : BackdropLayers(back: BlankBack(), front: FrontCurve(child: body()));
  }

  Widget body() => Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          walletChoices,
          components.containers.navBar(
            context,
            child: Row(children: <Widget>[previewButton]),
          )
        ],
      );

  Widget get walletChoices => Padding(
      padding:
          const EdgeInsets.only(left: 16.0, top: 16, right: 16, bottom: 40),
      child: TextFieldFormatted(
        controller: walletController,
        readOnly: true,
        labelText: 'Wallet',
        helperStyle: const TextStyle(color: AppColors.error),
        suffixIcon: IconButton(
          icon: const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: AppColors.black87)),
          onPressed: () => _produceWalletModal(),
        ),
        onTap: () {
          _produceWalletModal();
        },
        onEditingComplete: () async {
          FocusScope.of(context).requestFocus(previewFocus);
        },
      ));

  Widget get previewButton => components.buttons.actionButton(
        context,
        enabled: walletController.text != '',
        focusNode: previewFocus,
        onPressed: () async {
          Navigator.of(components.navigator.routeContext!).pushNamed(
            '/settings/export/export',
            arguments: <String, dynamic>{
              'struct': CheckoutStruct(
                icon: const Icon(Icons.account_balance_wallet_rounded,
                    size: 36, color: AppColors.primary),
                symbol: null,
                displaySymbol: walletController.text,
                subSymbol: null,
                paymentSymbol: null,
                left: .25,
                items: <List<String>>[
                  <String>['Location', await storage.localPath, '3'],
                  <String>['File', '$filePrefix$today.json', '2'],
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

  Widget get finalSubmitButtons => Row(children: <Widget>[
        components.buttons.actionButton(context,
            label: 'Share',
            onPressed: () => components.message
                .giveChoices(
                  context,
                  behaviors: <String, VoidCallback>{
                    'I saved it':
                        Navigator.of(components.navigator.routeContext!).pop
                  },
                  title: 'Encryption Key',
                  content:
                      'You will need the following key in order to decrypt your export:',
                  child:
                      const ShowAuthenticationChoice(title: null, desc: null),
                )
                .then((_) async =>
                    Share.share(await rawExport ?? 'Invalid wallet data'))),
        if (!Platform.isIOS) const SizedBox(width: 16),
        if (!Platform.isIOS)
          components.buttons.actionButton(
            context,
            label: 'Export',
            onPressed: () async {
              components.loading.screen(message: 'Exporting');
              file = await export();
              await Future<void>.delayed(const Duration(seconds: 1));
              if (file != null) {
                streams.app.snack.add(Snack(
                  message: 'Successfully Exported ${walletController.text}',
                ));
              } else {
                streams.app.snack.add(Snack(
                    message: 'Failed to Export ${walletController.text}'));
              }
            },
          )
      ]);

  Future<File?> export() async => storage.writeExport(
        filename: filePrefix + today,
        rawExport: await rawExport,
      );

  String get filePrefix => 'moontree_backup_';

  String get today =>
      '${DateTime.now().month}_${DateTime.now().day}_${DateTime.now().year.toString().substring(2)}';

  Future<String?> get rawExport async => wallets == null
      ? null
      : jsonEncode(await services.wallet.export.structureForExport(wallets!));

  Future<void> _produceWalletModal() async {
    await SelectionItems(context, modalSet: SelectionSet.Wallets)
        .build(controller: walletController);
    setState(() {/* to refresh and enable the button */});
  }
}
