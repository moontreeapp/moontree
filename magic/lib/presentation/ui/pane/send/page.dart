import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/pane/send/cubit.dart';
import 'package:magic/domain/concepts/send.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:magic/presentation/ui/pane/send/confirm.dart';
import 'package:magic/presentation/widgets/other/other.dart';
import 'package:magic/services/services.dart';
import 'package:wallet_utils/wallet_utils.dart';

class SendPage extends StatelessWidget {
  const SendPage({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<SendCubit, SendState>(
      buildWhen: (SendState prior, SendState current) =>
          prior.sendRequest != current.sendRequest ||
          prior.unsignedTransaction != current.sendRequest,
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

class SendContent extends StatelessWidget {
  const SendContent({super.key});

  void _send() {
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
      sendAddress: 'state.address',
      holding: 0,
      visibleAmount: '0',
      sendAmountAsSats: 0,
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
  }

  @override
  Widget build(BuildContext context) => Container(
      height: screen.pane.midHeight,
      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 24),
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.next,
              labelText: 'To',
              suffixIcon: Icon(Icons.qr_code_scanner, color: AppColors.black60),
            ),
            SizedBox(height: 4),
            TextFieldFormatted(
              autocorrect: false,
              textInputAction: TextInputAction.done,
              labelText: 'Amount',
            ),
          ],
        ),
        GestureDetector(
            onTap: _send,
            child: Container(
                height: 64,
                decoration: ShapeDecoration(
                  color: AppColors.success,
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
