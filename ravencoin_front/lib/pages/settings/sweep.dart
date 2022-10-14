import 'package:flutter/material.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/wallet/constants.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/widgets/widgets.dart';

class SweepPage extends StatefulWidget {
  @override
  _SweepPageState createState() => _SweepPageState();
}

class _SweepPageState extends State<SweepPage> {
  FocusNode destinationFocus = FocusNode();
  FocusNode submitFocus = FocusNode();
  bool? sweepCurrency = false;
  bool? sweepAssets = false;
  bool dropDownActive = false;
  String walletId = '';

  @override
  void initState() {
    super.initState();
    //streams.app.verify.add(false);

    // automatically choose currency if that's all we can sweep
    sweepCurrency = Current.holdingNames == ['RVN'];
  }

  @override
  void dispose() {
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
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 24, bottom: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text('Sweep',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                    Text(
                                      'Sweeping means moving all value from one wallet to another.',
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    ),
                                  ])),
                          // they mus hold assets in order to choose assets

                          Container(
                              alignment: Alignment.topLeft,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  SizedBox(height: 16),
                                  Text(
                                    'What would you like to sweep from the current wallet?',
                                    style:
                                        Theme.of(context).textTheme.bodyText2,
                                  ),
                                  SizedBox(height: 16),
                                  CheckboxListTile(
                                    title: Text('RVN'),
                                    value: sweepCurrency,
                                    onChanged: (newValue) => setState(
                                        () => sweepCurrency = newValue),
                                    controlAffinity:
                                        ListTileControlAffinity.leading,
                                  ),
                                  if (Current.holdingNames.length > 1)
                                    CheckboxListTile(
                                      enabled: Current.holdingNames.length > 1,
                                      title: Text('Assets'),
                                      value: sweepAssets,
                                      onChanged: (newValue) => setState(
                                          () => sweepAssets = newValue),
                                      controlAffinity:
                                          ListTileControlAffinity.leading,
                                    ),
                                ],
                              )),
                          if (enabled)
                            Container(
                                alignment: Alignment.topLeft,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    SizedBox(height: 16),
                                    Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          components.buttons.actionButtonSoft(
                                            context,
                                            enabled: true,
                                            label:
                                                '${walletId == '' ? 'Select' : 'Change'} Destination',
                                            focusNode: destinationFocus,
                                            disabledIcon: Icon(
                                                Icons.lock_rounded,
                                                color: AppColors.black38),
                                            onPressed: () async {
                                              if (!dropDownActive) {
                                                dropDownActive = true;
                                                await SimpleSelectionItems(
                                                  components
                                                      .navigator.routeContext!,
                                                  then: () =>
                                                      dropDownActive = false,
                                                  items: [
                                                        if (pros.settings
                                                                .developerMode ==
                                                            true)
                                                          ListTile(
                                                            visualDensity:
                                                                VisualDensity
                                                                    .compact,
                                                            onTap: () async {
                                                              Navigator.pop(
                                                                  components
                                                                      .navigator
                                                                      .routeContext!);
                                                              walletId =
                                                                  await generateWallet();
                                                              //await switchWallet(walletId);
                                                            },
                                                            leading: Icon(
                                                                Icons.add,
                                                                color: AppColors
                                                                    .primary),
                                                            title: Text(
                                                                'New Wallet',
                                                                style: Theme.of(
                                                                        context)
                                                                    .textTheme
                                                                    .bodyText1),
                                                          ),
                                                      ] +
                                                      [
                                                        for (Wallet wallet
                                                            in pros.wallets
                                                                .ordered)
                                                          if (wallet.id !=
                                                              Current.walletId)
                                                            ListTile(
                                                              visualDensity:
                                                                  VisualDensity
                                                                      .compact,
                                                              onTap: () async {
                                                                walletId =
                                                                    wallet.id;
                                                                Navigator.pop(
                                                                    components
                                                                        .navigator
                                                                        .routeContext!);
                                                              },
                                                              leading: Icon(
                                                                Icons
                                                                    .account_balance_wallet_rounded,
                                                                color: AppColors
                                                                    .primary,
                                                              ),
                                                              title: Text(
                                                                  wallet.name,
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .bodyText1),
                                                            )
                                                      ],
                                                ).build();
                                              }
                                              FocusScope.of(context)
                                                  .requestFocus(submitFocus);
                                            },
                                          )
                                        ]),
                                    SizedBox(height: 16),
                                    Center(
                                        child: Text(
                                      '${walletId == '' ? 'From: ' + Current.wallet.name : Current.wallet.name + ' → '}${walletId == '' ? '' : pros.wallets.primaryIndex.getOne(walletId)!.name}',
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(context).textTheme.bodyText2,
                                    )),
                                  ],
                                )),
                        ])),
                components.containers
                    .navBar(context, child: Row(children: [sweepButton]))
              ]))));

  bool get enabled => sweepCurrency == true || sweepAssets == true;

  Widget get sweepButton => components.buttons.actionButton(
        context,
        enabled: enabled && walletId != '',
        label: 'Sweep',
        focusNode: submitFocus,
        disabledIcon: Icon(Icons.lock_rounded, color: AppColors.black38),
        disabledOnPressed: () => components.message.giveChoices(context,
            title: !enabled ? 'Missing value' : 'Missing destination',
            content: !enabled
                ? 'Plesae specify what to sweep.'
                : 'Please select a destination wallet.',
            behaviors: {'ok': () => Navigator.pop(context)}),
        onPressed: () {
          services.transaction.sweep(
              from: Current.wallet,
              toWalletId: walletId,
              currency: sweepCurrency ?? false,
              assets: sweepAssets ?? false);
          components.loading.screen(
            message: 'Sweeping...',
            playCount: 3,
            returnHome: true,
          );
        },
        //link: '//password/change',
      );
}
