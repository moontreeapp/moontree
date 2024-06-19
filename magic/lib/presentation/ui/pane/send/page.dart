import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/fade/cubit.dart';
import 'package:magic/cubits/pane/send/cubit.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/send.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/pane/send/confirm.dart';
import 'package:magic/presentation/utils/animation.dart';
import 'package:magic/presentation/widgets/other/other.dart';
import 'package:magic/services/services.dart';
import 'package:wallet_utils/wallet_utils.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<SendCubit, SendState>(
      buildWhen: (SendState prior, SendState current) =>
          prior.sendRequest != current.sendRequest ||
          prior.unsignedTransaction != current.unsignedTransaction,
      builder: (BuildContext context, SendState state) {
        if (state.sendRequest == null) {
          return const SendContent();
        }
        if (state.unsignedTransaction == null) {
          return const ConfirmContent();
          return Container(
              height: screen.pane.midHeight,
              alignment: Alignment.center,
              child: const Text('please wait...'));
        }
        return const ConfirmContent();
      });
}

class SendContent extends StatefulWidget {
  const SendContent({super.key});
  @override
  SendContentState createState() => SendContentState();
}

class SendContentState extends State<SendContent> {
  final TextEditingController addressText =
      TextEditingController(text: cubits.send.state.address);
  final TextEditingController amountText =
      TextEditingController(text: cubits.send.state.amount);

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    addressText.dispose();
    amountText.dispose();
    super.dispose();
  }

// ignore: slash_for_doc_comments
/** validation
 * ETJ8zPcJiBYBxCdiiHt37xCfXRKVRuBsp7
  String _asDoubleString(double x) {
    if (x.toString().endsWith('.0')) {
      return x.toString().replaceAll('.0', '');
    }
    return x.toString();
  }

    bool _validateDivisibility([String? value]) =>
      (components.cubits.simpleSendForm.state.metadataView?.divisibility ??
          8) >=
      ((value ?? sendAmount.text).contains('.')
          ? (value ?? sendAmount.text).split('.').last.length
          : 0);
           bool _holdingValidation(SimpleSendFormState state) {
    final quantity = sendAmount.textWithoutCommas;
    if (_asDouble(quantity) == 0.0) {
      return false;
    }
    if (holdingBalance.security.isCoin) {
      // we have enough coin for the send and minimum fee estimate
      // actaully don't do this because we can send all.
      if (holdingBalance.amount == double.parse(quantity)) {
        return true;
      }
      // if not sending all:
      return holdingBalance.amount > double.parse(quantity) + 0.0021;
    } else {
      final BalanceView? holdingView =
          components.cubits.holdingsView.holdingsViewFor(Current.coin.symbol);
      // we have enough asset for the send and enough coin for minimum fee
      return holdingBalance.amount >= double.parse(quantity) &&
          holdingView!.satsConfirmed + holdingView.satsUnconfirmed > 210000;
    }
    //return (state.security.balance?.amount ?? 0) >=
    //    double.parse(sendAmount.textWithoutCommas);
  }
    final bool vAddress = sendAddress.text != '' && _validateAddress();
  bool _validateAddress([String? address]) {
    address ??= sendAddress.text;
    return address == '' ||
        (pros.settings.chain == Chain.ravencoin
            ? pros.settings.net == Net.main
                ? address.isAddressRVN
                : address.isAddressRVNt
            : pros.settings.net == Net.main
                ? address.isAddressEVR
                : address.isAddressEVRt);
  }

 */

  bool validateAddress(String address) =>
      validateAddressNotEmpty(address) && validateAddressByBlockchain(address);

  List<String> invalidAddressMessages(String address) => [
        if (!validateAddressNotEmpty(address)) 'cannot be empty',
        if (!validateAddressByBlockchain(address)) 'invalid',
      ];

  bool validateAddressNotEmpty(String address) => address.isNotEmpty;
  bool validateAddressByBlockchain(String address) =>
      (cubits.holding.state.holding.blockchain.isAddress(address));

  bool validateAmount(String amount) =>
      validateAmountNotEmpty(amount) &&
      validateAmountWithinDivisibility(amount) &&
      validateAmountAbleToParse(amount) &&
      validateAmountGTZero(amount) &&
      validateAmountByBlockchain(amount) &&
      validateAmountLTTotal(amount);

  List<String> invalidAmountMessages(String amount) => [
        if (!validateAmountNotEmpty(amount)) 'cannot be empty',
        if (!validateAmountWithinDivisibility(amount))
          'too many decimal places',
        if (!validateAmountAbleToParse(amount)) 'invalid',
        if (!validateAmountGTZero(amount)) 'must be greater than 0',
        if (!validateAmountByBlockchain(amount)) 'invalid',
        if (!validateAmountLTTotal(amount)) 'you do not have the much',
      ];

  bool validateAmountNotEmpty(String amount) => amount.isNotEmpty;
  bool validateAmountWithinDivisibility(String amount) =>
      amount.contains('.') ? amount.split('.').last.length <= 8 : true;
  bool validateAmountAbleToParse(String amount) =>
      double.tryParse(amount) != null;
  bool validateAmountGTZero(String amount) =>
      (double.tryParse(amount) ?? -1) > 0.000000009;
  bool validateAmountByBlockchain(String amount) =>
      (cubits.holding.state.holding.blockchain
              ?.isAmount((double.tryParse(amount) ?? -1)) ??
          false);
  bool validateAmountLTTotal(String amount) =>
      (cubits.holding.state.holding.coin.toDouble() >=
          (double.tryParse(amount) ?? -1));

  bool validateForm() =>
      validateAddress(cubits.send.state.address) &&
      validateAmount(cubits.send.state.amount);

  Future<void> _send() async {
    cubits.fade.update(fade: FadeEvent.fadeOut);
    // maybe we can shorten or remove: cubit may take more than that time anyway
    await Future.delayed(fadeDuration);

    // validate address is valid
    // validate amount is a valid amount
    // validate amount is less than amount we hold of this asset
    // validate memo?
    // generate a send request
    /**
        final SendRequest sendRequest = SendRequest(
          sendAll: holdingBalance.amount == state.amount,
          wallet: Current.wallet,
          sendAddress: state.address,
          holding: holdingBalance.amount,
          visibleAmount: _asDoubleString(state.amount),
          sendAmountAsSats: state.sats,
          feeRate: state.fee,
          security: state.security,
          assetMemo: state.security != pros.securities.currentCoin &&
                  state.memo != '' &&
                  state.memo.isIpfs
              ? state.memo
              : null,
          //TODO: Currently memos are only for non-asset transactions
          memo: state.security == pros.securities.currentCoin &&
                  state.memo != '' &&
                  _verifyMemo(state.memo)
              ? state.memo
              : null,
          note: state.note != '' ? state.note : null,
        );
    */

    cubits.send.update(
        sendRequest: SendRequest(
      sendAll: false,
      sendAddress: cubits.send.state.address,
      holding: cubits.holding.state.holding.coin.toDouble(),
      visibleAmount: cubits.send.state.amount,
      sendAmountAsSats:
          Coin.fromString(cubits.send.state.amount).toSats().value,
      feeRate: cheapFee,
      //security: state.security,
      // only for hard mode
      //assetMemo: state.security != pros.securities.currentCoin &&
      //        state.memo != '' &&
      //        state.memo.isIpfs
      //    ? state.memo
      //    : null,
      //memo: state.security == pros.securities.currentCoin &&
      //        state.memo != '' &&
      //        _verifyMemo(state.memo)
      //    ? state.memo
      //    : null,
      //note: state.note != '' ? state.note : null,
    ));

    // send the request
    // // _confirmSend(sendRequest, cubit);
    // go to the confirm page
    // on that page display results of transaction
    // sign it.
    cubits.send.setUnsignedTransaction(
      sendAllCoinFlag: false,
      symbol: cubits.holding.state.holding.symbol,
      blockchain: cubits.holding.state.holding.blockchain,
    );
    await Future.delayed(fadeDuration);
    cubits.fade.update(fade: FadeEvent.fadeIn);
  }

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.next,
              controller: addressText,
              labelText: 'To',
              suffixIcon:
                  const Icon(Icons.qr_code_scanner, color: AppColors.black60),
              errorText: addressText.text.trim() == '' ||
                      validateAddress(addressText.text)
                  ? null
                  : invalidAddressMessages(addressText.text).firstOrNull,
              onChanged: (value) => setState(() {
                if (validateAddress(addressText.text)) {
                  cubits.send.update(address: value);
                }
              }),
            ),
            const SizedBox(height: 4),
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.done,
              controller: amountText,
              labelText: 'Amount',
              errorText: amountText.text.trim() == '' ||
                      validateAmount(amountText.text)
                  ? null
                  : invalidAmountMessages(amountText.text).first,
              onChanged: (value) => setState(() {
                if (validateAmount(amountText.text)) {
                  cubits.send.update(amount: value);
                }
              }),
            ),
          ],
        ),
        GestureDetector(
            onTap: _send,
            child: Container(
                height: 64,
                decoration: ShapeDecoration(
                  color:
                      validateForm() ? AppColors.success : AppColors.disabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28 * 100),
                  ),
                ),
                child: Center(
                    child: Text(
                  'PREVIEW',
                  style: AppText.button1
                      .copyWith(fontSize: 16, color: Colors.white),
                )))),
      ]));
}
