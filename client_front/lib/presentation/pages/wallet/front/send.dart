import 'dart:io' show Platform;
import 'dart:async';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:wallet_utils/wallet_utils.dart'
    show FeeRate, SatsToAmountExtension;
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_back/server/src/protocol/comm_balance_view.dart';
import 'package:client_front/domain/concepts/fee.dart' as fees;
import 'package:client_front/domain/utils/params.dart';
import 'package:client_front/domain/utils/data.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/wallet/send/cubit.dart';
import 'package:client_front/application/layers/modal/bottom/cubit.dart';
import 'package:client_front/presentation/pages/wallet/scan.dart';
import 'package:client_front/presentation/services/services.dart';
import 'package:client_front/presentation/widgets/other/selection_control.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;

extension FunctionsForBalanceView on BalanceView {
  int get sats => satsConfirmed + satsUnconfirmed;
  double get amount => (satsConfirmed + satsUnconfirmed).asCoin;
}

class SimpleSend extends StatefulWidget {
  final dynamic data;
  const SimpleSend({Key? key, this.data}) : super(key: key);

  @override
  _SimpleSendState createState() => _SimpleSendState();
}

class _SimpleSendState extends State<SimpleSend> {
  Map<String, dynamic> data = <String, dynamic>{};
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  final TextEditingController sendAsset = TextEditingController();
  final TextEditingController sendAddress = TextEditingController();
  final TextEditingController sendAmount = TextEditingController();
  final TextEditingController sendFee = TextEditingController();
  final TextEditingController sendMemo = TextEditingController();
  final TextEditingController sendNote = TextEditingController();
  FocusNode sendAssetFocusNode = FocusNode();
  FocusNode sendAddressFocusNode = FocusNode();
  FocusNode sendAmountFocusNode = FocusNode();
  FocusNode sendFeeFocusNode = FocusNode();
  FocusNode sendMemoFocusNode = FocusNode();
  FocusNode sendNoteFocusNode = FocusNode();
  FocusNode previewFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  String addressName = '';
  String visibleAmount = '0';
  bool clicked = false;
  bool validatedAddress = true;
  late Balance holdingBalance;

  void scrollToItem(FocusNode focusNode, double offset, [double returnTo = 0]) {
    if (focusNode.hasFocus) {
      setState(() {});
      scrollController.animateTo(
          offset, //scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOutCubic);
    } else {
      scrollController.animateTo(returnTo,
          duration: Duration(milliseconds: 300), curve: Curves.easeInOutCubic);
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SimpleSendFormCubit>(context).reset();
    // Add a listener to the focus node
    sendAmountFocusNode
        .addListener(() => scrollToItem(sendAmountFocusNode, 70));
    sendFeeFocusNode.addListener(() => scrollToItem(sendFeeFocusNode, 130));
    sendMemoFocusNode.addListener(() => scrollToItem(sendMemoFocusNode, 190));
    sendNoteFocusNode
        .addListener(() => scrollToItem(sendNoteFocusNode, 250, 70));
  }

  @override
  void dispose() {
    sendAssetFocusNode.dispose();
    sendAddressFocusNode.dispose();
    sendAmountFocusNode.dispose();
    sendFeeFocusNode.dispose();
    sendMemoFocusNode.dispose();
    sendNoteFocusNode.dispose();
    previewFocusNode.dispose();
    sendAsset.dispose();
    sendAddress.dispose();
    sendAmount.dispose();
    sendFee.dispose();
    sendMemo.dispose();
    sendNote.dispose();
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void _announceNoCoin() => streams.app.behavior.snack.add(Snack(
        message: 'No coin in wallet - unable to pay fees',
        positive: false,
      ));

  void populateFromData(SimpleSendFormCubit cubit) {
    if (data.isNotEmpty) {
      if (<String?>[null, pros.settings.chain.name].contains(data['chain'])) {
        if (<String?>[null, pros.settings.net.name].contains(data['net'])) {
          cubit.set(
            security: data['security'] as Security? ?? cubit.state.security,
            address: data['address'] as String? ?? cubit.state.address,
            addressName:
                data['addressName'] as String? ?? cubit.state.addressName,
            amount: data['amount'] as double? ?? cubit.state.amount,
            fee: data['fee'] as FeeRate? ?? cubit.state.fee,
            memo: data['memo'] as String? ?? cubit.state.memo,
            note: data['note'] as String? ?? cubit.state.note,
          );
        } else {
          streams.app.behavior.snack.add(Snack(
            message: 'Not connected to ${data['chain']} ${data['net']}',
            positive: false,
          ));
        }
      } else {
        streams.app.behavior.snack.add(Snack(
          message: 'Not connected to ${data['chain']}',
          positive: false,
        ));
      }
      data = <String, dynamic>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final SimpleSendFormCubit cubit =
        BlocProvider.of<SimpleSendFormCubit>(context);
    data = populateData(context, data);
    populateFromData(cubit);
    return GestureDetector(
        onTap: () {
          // getting error on back button.
          try {
            FocusScope.of(context).unfocus();
          } catch (e) {
            return;
          }
        },
        child: BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, SimpleSendFormState state) {
              // instead of using balances, which is unreliable, use holdingView
              final BalanceView? holdingView = components.cubits.holdingsView
                  .holdingsViewFor(state.security.symbol);
              holdingBalance = Balance(
                  walletId: Current.walletId,
                  security: state.security,
                  confirmed: holdingView?.satsConfirmed ?? 0,
                  unconfirmed: holdingView?.satsUnconfirmed ?? 0);
              // carry on
              sendAsset.text = state.security.name;
              if (state.amount > 0) {
                final String text = enforceDivisibility(
                  _asDoubleString(state.amount),
                  divisibility: state.security.divisibility,
                );
                sendAmount.value = TextEditingValue(
                    text: text,
                    selection: sendAmount.selection.baseOffset > text.length ||
                            (sendAmount.selection.baseOffset == 2 &&

                                /// this is the case that they typed .x and it replaced it with 0.x
                                text.length == 3 &&
                                text.startsWith('0.'))
                        ? TextSelection.collapsed(offset: text.length)
                        : sendAmount.selection);
              }
              if (state.memo.length > 0) {
                sendMemo.value = TextEditingValue(
                    text: state.memo,
                    selection: sendMemo.selection.baseOffset > state.memo.length
                        ? TextSelection.collapsed(offset: state.memo.length)
                        : sendMemo.selection);
              }
              if (state.note.length > 0) {
                sendNote.value = TextEditingValue(
                    text: state.note,
                    selection: sendNote.selection.baseOffset > state.note.length
                        ? TextSelection.collapsed(offset: state.note.length)
                        : sendNote.selection);
              }
              if (state.address.length > 0) {
                sendAddress.value = TextEditingValue(
                    text: state.address,
                    selection: sendAddress.selection.baseOffset >
                            state.address.length
                        ? TextSelection.collapsed(offset: state.address.length)
                        : sendAddress.selection);
              }
              sendFee.text = state.fee.name!;
              return Stack(
                children: <Widget>[
                  ListView(
                    physics: const ClampingScrollPhysics(),
                    controller: scrollController,
                    padding:
                        const EdgeInsets.only(left: 16, right: 16, top: 16),
                    children: <Widget>[
                      if (Platform.isIOS) const SizedBox(height: 8),
                      const SizedBox(height: 8),
                      ...<Widget>[
                        TextFieldFormatted(
                          key: Key('sendAsset'),
                          focusNode: sendAssetFocusNode,
                          controller: sendAsset,
                          readOnly: true,
                          textInputAction: TextInputAction.next,
                          prefixIcon: SizedBox(
                              height: 16,
                              width: 16,
                              child: Padding(
                                  padding: EdgeInsets.all(8),
                                  child: components.icons.assetAvatar(
                                      holdingView!.symbol,
                                      net: pros.settings.net))),
                          //decoration: styles.decorations.textField(context,
                          //    focusNode: sendAssetFocusNode,
                          //    labelText: 'Asset',
                          //    hintText: pros.settings.chain.title,
                          //    prefixIcon: components.icons.assetAvatar(
                          //        holdingView!.symbol,
                          //        net: pros.settings.net)),
                          suffixIcon: IconButton(
                              icon: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: SvgPicture.asset(
                                      'assets/icons/custom/black/chevron-down.svg')
                                  //Icon(Icons.expand_more_rounded,
                                  //    color: AppColors.black60)
                                  ),
                              onPressed: () => _produceAssetModal(cubit)),
                          onTap: () => _produceAssetModal(cubit),
                          onChanged: (String value) {},
                          onEditingComplete: () async {
                            FocusScope.of(context)
                                .requestFocus(sendAddressFocusNode);
                          },
                        ),
                        if (addressName != '') Text('To: $addressName'),
                        TextFieldFormatted(
                          key: Key('sendAddress'),
                          focusNode: sendAddressFocusNode,
                          controller: sendAddress,
                          textInputAction: TextInputAction.next,
                          selectionControls:
                              CustomMaterialTextSelectionControls(
                                  context: components.routes.routeContext,
                                  offset: Offset.zero),
                          autocorrect: false,
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'),
                                allow: true)
                          ],
                          labelText: 'To',
                          hintText: 'Address',
                          errorText: sendAddress.text != '' &&
                                  !_validateAddress(sendAddress.text)
                              ? 'Unrecognized Address'
                              : null,
                          suffixIcon: IconButton(
                              icon: Padding(
                                padding: const EdgeInsets.only(right: 14),
                                child: SvgPicture.asset(
                                    'assets/icons/custom/black/qrcode.svg'),
                                //Icon(Icons.qr_code_scanner_rounded,
                                //    color: AppColors.black60)
                              ),
                              onPressed: () async => cubit.set(
                                  address: (await _produceScanModal()))),
                          onChanged: (String value) =>
                              cubit.set(address: value),
                          onEditingComplete: () {
                            cubit.set(address: sendAddress.text);
                            FocusScope.of(context)
                                .requestFocus(sendAmountFocusNode);
                          },
                        ),
                        TextFieldFormatted(
                          key: Key('sendAmount'),
                          focusNode: sendAmountFocusNode,
                          controller: sendAmount,
                          textInputAction: TextInputAction.next,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatters: <TextInputFormatter>[
                            //DecimalTextInputFormatter(decimalRange: divisibility)
                            FilteringTextInputFormatter(
                                //RegExp(r'[.0-9]'),
                                RegExp(r'^[0-9]*(\.[0-9]{0,' +
                                    '${components.cubits.simpleSendForm.state.metadataView?.divisibility ?? 8}' +
                                    r'})?'),
                                allow: true)
                          ],
                          labelText: 'Amount',
                          hintText: 'Quantity',
                          errorText: (String x) {
                            if (x == '') {
                              return null;
                            }
                            if (x == '0') {
                              return 'must be greater than 0';
                            }
                            if (_asDouble(x) > holdingBalance.amount) {
                              return 'too large';
                            }
                            if (x.isNumeric) {
                              final num? y = x.toNum();
                              if (y != null && y.isRVNAmount) {
                                return null;
                              }
                            }
                            return 'Unrecognized Amount';
                          }(sendAmount.text),
                          // put ability to put it in as USD here
                          /* // functionality has been moved to header
                                  suffixText: sendAll ? "don't send all" : 'send all',
                                  suffixStyle: Theme.of(context).textTheme.bodySmall,
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                        sendAll ? Icons.not_interested : Icons.all_inclusive,
                                        color: Color(0xFF606060)),
                                    onPressed: () {
                                      if (!sendAll) {
                                        sendAll = true;
                                        sendAmount.text = holding.toString();
                                      } else {
                                        sendAll = false;
                                        sendAmount.text = '';
                                      }
                                    },
                                  ),
                                  */
                          onChanged: (String value) {
                            try {
                              cubit.set(amount: double.parse(value));
                            } catch (e) {
                              cubit.set(amount: 0);
                            }
                          },
                          onEditingComplete: () {
                            String value = sendAmount.text;
                            try {
                              cubit.set(amount: double.parse(value));
                            } catch (e) {
                              cubit.set(amount: 0);
                            }

                            //// causes error on ios. as the keyboard becomes dismissed the bottom modal sheet is attempting to appear, they collide.
                            //FocusScope.of(context).requestFocus(sendFeeFocusNode);
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        TextFieldFormatted(
                          key: Key('sendFee'),
                          onTap: () => _produceFeeModal(cubit),
                          focusNode: sendFeeFocusNode,
                          controller: sendFee,
                          readOnly: true,
                          textInputAction: TextInputAction.next,
                          labelText: 'Transaction Speed',
                          hintText: 'Standard',
                          suffixIcon: IconButton(
                              icon: Padding(
                                  padding: const EdgeInsets.only(right: 14),
                                  child: SvgPicture.asset(
                                      'assets/icons/custom/black/chevron-down.svg')
                                  //Icon(Icons.expand_more_rounded,
                                  //    color: AppColors.black60)
                                  ),
                              onPressed: () => _produceFeeModal(cubit)),
                          onChanged: (String newValue) {
                            //sendFee.text = newValue; //necessary?
                            //cubit.set(
                            //    fee: {
                            //          'Cheap': ravencoin.FeeRates.cheap,
                            //          'Standard':
                            //              ravencoin.FeeRates.standard,
                            //          'Fast': ravencoin.FeeRates.fast,
                            //        }[newValue] ??
                            //        ravencoin.FeeRates.standard);
                            //cubit.set(fee: feeConcept.feeRate);
                            FocusScope.of(context)
                                .requestFocus(sendFeeFocusNode);
                          },
                        ),
                        TextFieldFormatted(
                            key: Key('sendMemo'),
                            focusNode: sendMemoFocusNode,
                            controller: sendMemo,
                            textInputAction: TextInputAction.next,
                            labelText: 'Memo',
                            hintText: 'IPFS',
                            helperText: sendMemoFocusNode.hasFocus
                                ? 'will be saved on the blockchain'
                                : null,
                            helperStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(height: .7, color: AppColors.primary),
                            errorText: _verifyMemo() ? null : 'too long',
                            /*suffixIcon: IconButton(
                                icon: const Icon(Icons.paste_rounded,
                                    color: AppColors.black60),
                                onPressed: () async => cubit.set(
                                    memo:
                                        (await Clipboard.getData('text/plain'))
                                                ?.text ??
                                            '')),*/
                            onChanged: (String value) => cubit.set(memo: value),
                            onEditingComplete: () {
                              cubit.set(memo: sendMemo.text);
                              FocusScope.of(context)
                                  .requestFocus(sendNoteFocusNode);
                            }),
                        TextFieldFormatted(
                            key: Key('sendNote'),
                            focusNode: sendNoteFocusNode,
                            controller: sendNote,
                            textInputAction: TextInputAction.next,
                            labelText: 'Note',
                            hintText: 'Purchase',
                            helperText: sendNoteFocusNode.hasFocus
                                ? 'will be saved to your phone'
                                : null,
                            helperStyle: Theme.of(context)
                                .textTheme
                                .bodySmall!
                                .copyWith(height: .7, color: AppColors.primary),
                            /*suffixIcon: IconButton(
                                icon: const Icon(Icons.paste_rounded,
                                    color: AppColors.black60),
                                onPressed: () async => cubit.set(
                                    note:
                                        (await Clipboard.getData('text/plain'))
                                                ?.text ??
                                            '')),*/
                            onChanged: (String value) => cubit.set(note: value),
                            onEditingComplete: () {
                              cubit.set(note: sendNote.text);
                              FocusScope.of(context)
                                  .requestFocus(previewFocusNode);
                            }),
                      ].intersperse(const SizedBox(height: 16)),
                      const SizedBox(height: 64),
                      const SizedBox(height: 40),
                      SizedBox(
                          height: (sendAmountFocusNode.hasFocus ||
                                  sendFeeFocusNode.hasFocus ||
                                  sendMemoFocusNode.hasFocus ||
                                  sendNoteFocusNode.hasFocus)
                              ? screen.frontContainer.midHeight / 2
                              : 0),
                    ],
                  ),
                  Container(
                      alignment: Alignment.bottomCenter,
                      height: screen.frontContainer.midHeight,
                      child: FrontCurve(
                        fuzzyTop: false,
                        height: screen.buttonHeight + 24 + 24,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(
                                    top: 24, right: 16, bottom: 24, left: 16),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      Expanded(
                                          child: BottomButton(
                                        focusNode: previewFocusNode,
                                        enabled:
                                            _allValidation(state) && !clicked,
                                        label: !clicked
                                            ? 'Preview'
                                            : 'Generating Transaction...',
                                        onPressed: () {
                                          setState(() {
                                            clicked = true;
                                          });
                                          _startSend(cubit, state);
                                        },
                                        disabledOnPressed: () {
                                          if (!_coinValidation()) {
                                            _announceNoCoin();
                                          }
                                        },
                                      ))
                                    ])),
                          ],
                        ),
                      ))
                ],
              );
            }));
  }

  double _asDouble(String x) {
    try {
      if (double.parse(x) == 0.0) {
        return 0;
      }
    } catch (e) {
      return 0;
    }
    return double.parse(x);
  }

  String _asDoubleString(double x) {
    if (x.toString().endsWith('.0')) {
      return x.toString().replaceAll('.0', '');
    }
    return x.toString();
  }

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

  bool _verifyMemo([String? memo]) =>
      (memo ?? sendMemo.text).isMemo || (memo ?? sendMemo.text).isIpfs;

  bool _coinValidation() => holdingBalance.value > 0;
  //pros.balances.primaryIndex
  //    .getOne(Current.walletId, pros.securities.currentCoin) !=
  //null;

  bool _validateDivisibility() =>
      (components.cubits.simpleSendForm.state.metadataView?.divisibility ??
          8) >=
      (sendAmount.text.contains('.')
          ? sendAmount.text.split('.').last.length
          : 0);

  bool _fieldValidation() =>
      sendAddress.text != '' &&
      _validateAddress() &&
      _validateDivisibility() &&
      _verifyMemo();

  bool _holdingValidation(SimpleSendFormState state) {
    if (_asDouble(sendAmount.text) == 0.0) {
      return false;
    }
    if (holdingBalance.security.isCoin) {
      // we have enough coin for the send and minimum fee estimate
      // actaully don't do this because we can send all.
      if (holdingBalance.amount == double.parse(sendAmount.text)) {
        return true;
      }
      // if not sending all:
      return holdingBalance.amount > double.parse(sendAmount.text) + 0.0021;
    } else {
      final BalanceView? holdingView =
          components.cubits.holdingsView.holdingsViewFor(Current.coin.symbol);
      // we have enough asset for the send and enough coin for minimum fee
      return holdingBalance.amount >= double.parse(sendAmount.text) &&
          holdingView!.satsConfirmed + holdingView.satsUnconfirmed > 210000;
    }
    //return (state.security.balance?.amount ?? 0) >=
    //    double.parse(sendAmount.text);
  }

  bool _allValidation(SimpleSendFormState state) =>
      /*_coinValidation() && */ _fieldValidation() && _holdingValidation(state);

  void _startSend(SimpleSendFormCubit cubit, SimpleSendFormState state) {
    final bool vAddress = sendAddress.text != '' && _validateAddress();
    final bool vMemo = _verifyMemo();
    if (vAddress && vMemo) {
      FocusScope.of(context).unfocus();
      if (holdingBalance.amount >= double.parse(sendAmount.text)) {
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
        _confirmSend(sendRequest, cubit);
      }
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate proclaim? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....

  void _confirmSend(SendRequest sendRequest, SimpleSendFormCubit cubit) async {
    //streams.spend.make.add(sendRequest); // using cubit instead, poorly
    await cubit.setUnsignedTransaction(
      sendAllCoinFlag: cubit.state.security.isCoin && sendRequest.sendAll,
      symbol: cubit.state.security.symbol,
      wallet: Current.wallet,
      chain: Current.chain,
      net: Current.net,
    );
    // this check should live in repository or something, todo: fix
    if (cubit.state.unsigned == null) {
      streams.app.behavior.snack.add(Snack(
          message: 'Unable to contact server. Please try again later.',
          positive: false));
      return;
    }
    for (final unsigned in cubit.state.unsigned ?? []) {
      if (unsigned.error != null) {
        streams.app.behavior.snack.add(Snack(
          message: unsigned.error ?? 'Unable to make transaction at this time.',
          positive: false,
        ));
        return;
      }
    }
    //streams.spend.made.add(TransactionNote(
    //  txHex: cubit.state.unsigned![0].rawHex,
    //  note: sendRequest.note,
    //));
    cubit.set(
        checkout: SimpleSendCheckoutForm(
      symbol: sendRequest.security!.symbol,
      displaySymbol: sendRequest.security!.name,
      subSymbol: '',
      paymentSymbol: pros.securities.currentCoin.symbol,
      items: <List<String>>[
        <String>['To', sendRequest.sendAddress],
        if (addressName != '') <String>['Known As', addressName],
        <String>[
          'Amount',
          if (sendRequest.sendAll)
            'calculating amount...'
          else
            sendRequest.visibleAmount
        ],
        if (!<String?>['', null].contains(sendRequest.memo))
          <String>['Memo', sendRequest.memo!],
        if (!<String?>['', null].contains(sendRequest.note))
          <String>['Note', sendRequest.note!],
      ],
      fees: <List<String>>[
        <String>['Transaction Fee', 'calculating fee...']
      ],
      total: 'calculating total...',
      buttonAction: () async {
        // ideally this should be done here, just befor broadcast, but we
        // have to generate and sign transaction to verify fees, etc prior
        //await cubit.sign();

        // broadcast signed trasnaction -- commented out for testing verification
        await cubit.broadcast();
        //sail.home();
      },
      buttonWord: 'Send',
      loadingMessage: 'Sending',
      estimate: SendEstimate(
        sendRequest.sendAmountAsSats,
        sendAll: sendRequest.sendAll,
        fees: 0,
        //utxos: null, // in string form at cubit.state.unsigned.vinPrivateKeySource
        security: cubit.state.security,
        //assetMemo: Uint8List.fromList(cubit.state.memo
        //    .codeUnits), // todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
        memo: cubit.state.memo, // todo: correct?memo,
        creation: false,
      ),
    ));
    //streams.spend.estimate.add(SendEstimate(
    //  sendRequest.sendAmountAsSats,
    //  sendAll: sendRequest.sendAll,
    //  fees: 412000, // estimate. server doesn't tell us yet
    //  utxos: null, // in string form at cubit.state.unsigned.vinPrivateKeySource
    //  security: cubit.state.security,
    //  //assetMemo: Uint8List.fromList(cubit.state.memo
    //  //    .codeUnits), // todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
    //  memo: cubit.state.memo, // todo: correct?memo,
    //  creation: false,
    //));

    setState(() => clicked = false);
    await cubit.sign();
    final validateMsg = await cubit.verifyTransaction();
    if (validateMsg.item1) {
      sail.to('/wallet/send/checkout');
    } else {
      streams.app.behavior.snack.add(Snack(
          message: 'unable to generate transaction',
          positive: false,
          copy: validateMsg.item2,
          label: 'copy'));
    }
  }

  void _produceAssetModal(SimpleSendFormCubit cubit) =>
      components.cubits.bottomModalSheet.show(children: <Widget>[
        for (String name in Current.holdingNames
                .where(
                    (String item) => item == pros.securities.currentCoin.symbol)
                .toList() +
            Current.holdingNames
                .where(
                    (String item) => item != pros.securities.currentCoin.symbol)
                .toList())
          ListTile(
              onTap: () {
                context.read<BottomModalSheetCubit>().hide();
                final sec = pros.securities.ofCurrent(nameSymbol(name)) ??
                    pros.securities.currentCoin;
                cubit.set(security: sec);
                cubit.setMetadataView(security: sec);
              },
              leading: components.icons.assetAvatar(
                  name == 'Ravencoin'
                      ? pros.securities.RVN.symbol
                      : name == 'Evrmore'
                          ? pros.securities.EVR.symbol
                          : name,
                  height: 24,
                  width: 24,
                  net: pros.settings.net),
              title: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(symbolName(name),
                      style: Theme.of(context).textTheme.bodyLarge)))
      ]);

  void _produceFeeModal(SimpleSendFormCubit cubit) =>
      components.cubits.bottomModalSheet.show(children: <Widget>[
        for (final fees.FeeConcept feeConcept in <fees.FeeConcept>[
          fees.fast,
          fees.standard
        ])
          ListTile(
            onTap: () {
              context.read<BottomModalSheetCubit>().hide();
              cubit.set(fee: feeConcept.feeRate);
            },
            leading: feeConcept.icon,
            title: Text(feeConcept.title,
                style: Theme.of(context).textTheme.bodyLarge),
          )
      ]);

  Future<String> _produceScanModal() async {
    components.cubits.bottomModalSheet.show(
        childrenHeight: screen.frontContainer.midHeight ~/ 1,
        fullscreen: false,
        color: Colors.transparent,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            height: screen.frontContainer.midHeight,
            child: ScanQR(),
          ),
        ]);
    //components.cubits.bottomModalSheet.reset();
    /* return await value produced */
    return '';
  }
}
