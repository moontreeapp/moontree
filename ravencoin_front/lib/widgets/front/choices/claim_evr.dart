/// button that initiates the claim process.
/// here are the two main functionalities we need:
///   in order to show this button in the first place...
///     we must be able to detect if their evr is in the same address as the
///     initial snapshot (genesis block).
///   and we must be able to initiate the claim process, which is either just a sweep of this wallet to a new one, automatically created, or a simple send to a new wallet, also automatically created.
/// besides that we might need specialized UI.

import 'package:flutter/material.dart';

import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/services/wallet.dart';
import 'package:ravencoin_front/theme/colors.dart';

class ClaimEvr extends StatefulWidget {
  final dynamic data;
  const ClaimEvr({this.data}) : super();

  @override
  _ClaimEvr createState() => _ClaimEvr();
}

class _ClaimEvr extends State<ClaimEvr> {
  final submitFocus = FocusNode();
  bool clicked = false;
  late Wallet wallet;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [submitButton]);

  Widget get submitButton => TextButton(
      onPressed: () async {
        if (!clicked) {
          setState(() => clicked = true);
          await components.loading.screen(
              context: context,
              message: 'Generating Transaction...',
              returnHome: false,
              playCount: 1);
          final walletId = await generateWallet();
          wallet = pros.wallets.primaryIndex.getOne(walletId)!;
          confirmSend();
        }
      },
      child: Text('Claim',
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(color: AppColors.primary)));

  void confirmSend() {
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          icon: Icon(Icons.account_balance_wallet_rounded,
              color: AppColors.primary),
          symbol: null,
          displaySymbol: 'Claim EVR',
          subSymbol: null,
          paymentSymbol: null,
          items: [
            ['To', wallet.name],
            [
              'EVR',
              components.text.securityAsReadable(Current.balanceCurrency.value,
                  security: Current.balanceCurrency.security, asUSD: false)
            ],
          ],
          fees: null,
          total: null,
          confirm: 'Press Claim to complete transaction.',
          buttonAction: () async {
            await services.transaction.claim(
                from: Current.wallet,
                toWalletId: wallet.id,
                note: 'Claim EVR',
                msg: 'Successfully Claimed EVR');
            await switchWallet(wallet.id);
          },
          buttonWord: 'Claim',
          loadingMessage: 'Claiming',
        )
      },
    );
    setState(() => clicked = false);
  }
}
