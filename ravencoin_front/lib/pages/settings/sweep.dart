import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' show TxGoals, TxGoal;

class SweepPage extends StatefulWidget {
  @override
  _SweepPageState createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> {
  final toFocus = FocusNode();
  final feeFocus = FocusNode();
  final memoFocus = FocusNode();
  final noteFocus = FocusNode();
  final submitFocus = FocusNode();
  final fromController = TextEditingController();
  final toController = TextEditingController();
  final feeController = TextEditingController();
  final memoController = TextEditingController();
  final noteController = TextEditingController();

  //bool sweepCurrency = true;
  //bool sweepAssets = true;
  bool dropDownActive = false;
  String walletId = '';
  TxGoal fee = TxGoals.standard;
  String clipboard = '';
  bool clicked = false;

  @override
  void initState() {
    super.initState();
    fromController.text = Current.wallet.name;
    feeController.text = 'Standard';
  }

  @override
  void dispose() {
    toFocus.dispose();
    feeFocus.dispose();
    memoFocus.dispose();
    noteFocus.dispose();
    submitFocus.dispose();
    fromController.dispose();
    toController.dispose();
    feeController.dispose();
    memoController.dispose();
    noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BackdropLayers(
      back: BlankBack(),
      front: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: FrontCurve(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(left: 16, right: 16, top: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          /// from
                          TextFieldFormatted(
                            controller: fromController,
                            readOnly: true,
                            labelText: 'From',
                            enabled: false,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(toFocus);
                            },
                          ),
                          SizedBox(height: 16),

                          /// to
                          TextFieldFormatted(
                            focusNode: toFocus,
                            controller: toController,
                            readOnly: true,
                            labelText: 'To',
                            suffixIcon: IconButton(
                              icon: Padding(
                                  padding: EdgeInsets.only(right: 14),
                                  child: Icon(Icons.expand_more_rounded,
                                      color: Color(0xDE000000))),
                              onPressed: _produceToModal,
                            ),
                            onTap: _produceToModal,
                            onEditingComplete: () async {
                              FocusScope.of(context).requestFocus(feeFocus);
                            },
                          ),
                          SizedBox(height: 16),

                          /// fee
                          TextFieldFormatted(
                            focusNode: feeFocus,
                            controller: feeController,
                            readOnly: true,
                            textInputAction: TextInputAction.next,
                            labelText: 'Transaction Speed',
                            hintText: 'Standard',
                            suffixIcon: IconButton(
                              icon: Padding(
                                  padding: EdgeInsets.only(right: 14),
                                  child: Icon(Icons.expand_more_rounded,
                                      color: Color(0xDE000000))),
                              onPressed: () => _produceFeeModal(),
                            ),
                            onTap: () {
                              _produceFeeModal();
                              setState(() {});
                            },
                            onChanged: (String? newValue) {
                              FocusScope.of(context).requestFocus(memoFocus);
                              setState(() {});
                            },
                          ),
                          SizedBox(height: 16),

                          /// memo
                          TextFieldFormatted(
                              onTap: () async {
                                clipboard =
                                    (await Clipboard.getData('text/plain'))
                                            ?.text ??
                                        '';
                                setState(() {});
                              },
                              focusNode: memoFocus,
                              controller: memoController,
                              textInputAction: TextInputAction.next,
                              labelText: 'Memo',
                              hintText: 'IPFS',
                              helperText: memoFocus.hasFocus
                                  ? 'will be saved on the blockchain'
                                  : null,
                              helperStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      height: .7, color: AppColors.primary),
                              errorText: verifyMemo() ? null : 'too long',
                              suffixIcon:
                                  clipboard.isAssetData || clipboard.isIpfs
                                      ? IconButton(
                                          icon: Icon(Icons.paste_rounded,
                                              color: AppColors.black60),
                                          onPressed: () async {
                                            memoController.text =
                                                (await Clipboard.getData(
                                                            'text/plain'))
                                                        ?.text ??
                                                    '';
                                          })
                                      : null,
                              onChanged: (value) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                FocusScope.of(context).requestFocus(noteFocus);
                                setState(() {});
                              }),
                          SizedBox(height: 16),

                          /// note
                          TextFieldFormatted(
                              onTap: () async {
                                clipboard =
                                    (await Clipboard.getData('text/plain'))
                                            ?.text ??
                                        '';
                                setState(() {});
                              },
                              focusNode: noteFocus,
                              controller: noteController,
                              textInputAction: TextInputAction.next,
                              labelText: 'Note',
                              hintText: 'Purchase',
                              helperText: noteFocus.hasFocus
                                  ? 'will be saved to your phone'
                                  : null,
                              helperStyle: Theme.of(context)
                                  .textTheme
                                  .caption!
                                  .copyWith(
                                      height: .7, color: AppColors.primary),
                              suffixIcon: clipboard == '' ||
                                      clipboard.isIpfs ||
                                      clipboard.isAddressRVN ||
                                      clipboard.isAddressRVNt
                                  ? null
                                  : IconButton(
                                      icon: Icon(Icons.paste_rounded,
                                          color: AppColors.black60),
                                      onPressed: () async {
                                        noteController.text =
                                            (await Clipboard.getData(
                                                        'text/plain'))
                                                    ?.text ??
                                                '';
                                      },
                                    ),
                              onChanged: (value) {
                                setState(() {});
                              },
                              onEditingComplete: () {
                                FocusScope.of(context)
                                    .requestFocus(submitFocus);
                                setState(() {});
                              })
                        ])),
                KeyboardHidesWidgetWithDelay(
                  child: components.containers
                      .navBar(context, child: Row(children: [submitButton])),
                )
              ]))));

  Future<void> _produceToModal() async {
    if (!dropDownActive) {
      dropDownActive = true;
      await SimpleSelectionItems(
        components.navigator.routeContext!,
        then: () => dropDownActive = false,
        items: [
              ListTile(
                visualDensity: VisualDensity.compact,
                onTap: () async {
                  Navigator.pop(components.navigator.routeContext!);
                  walletId = await generateWallet();
                  toController.text =
                      pros.wallets.primaryIndex.getOne(walletId)!.name;
                },
                leading: Icon(Icons.add, color: AppColors.primary),
                title: Text('New Wallet',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
            ] +
            [
              for (Wallet wallet in pros.wallets.ordered)
                if (wallet.id != Current.walletId)
                  ListTile(
                    visualDensity: VisualDensity.compact,
                    onTap: () async {
                      walletId = wallet.id;
                      toController.text = wallet.name;
                      Navigator.pop(components.navigator.routeContext!);
                    },
                    leading: Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.primary,
                    ),
                    title: Text(wallet.name,
                        style: Theme.of(context).textTheme.bodyText1),
                  )
            ],
      ).build();
    }
    setState(() {});
    FocusScope.of(context).requestFocus(submitFocus);
  }

  Future<void> _produceFeeModal() async {
    if (!dropDownActive) {
      dropDownActive = true;
      await SimpleSelectionItems(
        components.navigator.routeContext!,
        then: () => dropDownActive = false,
        items: [
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () async {
              Navigator.pop(components.navigator.routeContext!);
              fee = TxGoals.standard;
              feeController.text = 'Standard';
            },
            leading: Icon(MdiIcons.speedometerMedium, color: AppColors.primary),
            title:
                Text('Standard', style: Theme.of(context).textTheme.bodyText1),
          ),
          ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () async {
              Navigator.pop(components.navigator.routeContext!);
              fee = TxGoals.fast;
              feeController.text = 'Fast';
            },
            leading: Icon(MdiIcons.speedometer, color: AppColors.primary),
            title: Text('Fast', style: Theme.of(context).textTheme.bodyText1),
          ),
        ],
      ).build();
    }
    FocusScope.of(context).requestFocus(submitFocus);
  }

  bool verifyMemo([String? memo]) =>
      (memo ?? memoController.text).isMemo ||
      (memo ?? memoController.text).isIpfs;

  bool get enabled => toController.text != '' && walletId != '';

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: submitFocus,
        enabled: enabled && !clicked,
        label: !clicked ? 'Preview' : 'Generating Transaction...',
        onPressed: () {
          setState(() => clicked = true);
          confirmSend();
        },
        //link: '//password/change',
      );

  void confirmSend() {
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          icon: Icon(Icons.account_balance_wallet_rounded,
              color: AppColors.primary),
          symbol: null,
          displaySymbol: fromController.text,
          subSymbol: null,
          paymentSymbol: null,
          items: [
            ['To', toController.text],
            ['Amount', 'All Coins and Assets'],
            if (memoController.text != '') ['Memo', memoController.text],
            if (noteController.text != '') ['Note', noteController.text],
          ],
          fees: null,
          total: null,
          confirm:
              "Are you sure you want to sweep all of this wallet's coins and assets?",
          playcount: 10,
          buttonAction: () async {
            services.transaction.sweep(
                from: Current.wallet,
                toWalletId: walletId,
                currency: true,
                assets: true,
                memo: memoController.text == '' ? null : memoController.text,
                note: noteController.text == '' ? null : noteController.text);
            //await components.loading.screen(
            //  message: 'Sweeping',
            //  playCount: 3,
            //  returnHome: true,
            //);
            //streams.app.snack.add(Snack(message: 'Successfully Swept'));
          },
          buttonWord: 'Sweep',
          loadingMessage: 'Sweeping',
        )
      },
    );
    setState(() => clicked = false);
  }
}
