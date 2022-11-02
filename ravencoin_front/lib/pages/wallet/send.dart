import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/utils/qrcode.dart';

import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

import 'package:ravencoin_back/streams/spend.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/streams/app.dart';

import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/utils/params.dart';
import 'package:ravencoin_front/utils/data.dart';

class Send extends StatefulWidget {
  final dynamic data;
  const Send({this.data}) : super();

  @override
  _SendState createState() => _SendState();
}

class _SendState extends State<Send> {
  Map<String, dynamic> data = {};
  List<StreamSubscription> listeners = [];
  SpendForm? spendForm;
  late Security security;
  double? minHeight;
  final sendAsset = TextEditingController();
  final sendAddress = TextEditingController();
  final sendAmount = TextEditingController();
  final sendFee = TextEditingController();
  final sendMemo = TextEditingController();
  final sendNote = TextEditingController();
  late int divisibility = 8;
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  bool validatedAddress = true;
  String validatedAmount = '-1';
  bool useWallet = false;
  double holding = 0.0;
  FocusNode sendAssetFocusNode = FocusNode();
  FocusNode sendAddressFocusNode = FocusNode();
  FocusNode sendAmountFocusNode = FocusNode();
  FocusNode sendFeeFocusNode = FocusNode();
  FocusNode sendMemoFocusNode = FocusNode();
  FocusNode sendNoteFocusNode = FocusNode();
  FocusNode previewFocusNode = FocusNode();
  ravencoin.TxGoal feeGoal = ravencoin.TxGoals.standard;
  String addressName = '';
  bool showPaste = false;
  String clipboard = '';
  final ScrollController scrollController = ScrollController();
  bool clicked = false;

  bool rvnValidation() =>
      pros.balances.primaryIndex
          .getOne(Current.walletId, pros.securities.currentCurrency) !=
      null;

  void tellUserNoRVN() => streams.app.snack.add(Snack(
        message: 'No Ravencoin in wallet - fees are paid in Ravencoin',
        positive: false,
      ));

  @override
  void initState() {
    super.initState();
    //minHeight = 1 - (201 + 16) / MediaQuery.of(context).size.height;
    if (!rvnValidation()) {
      tellUserNoRVN();
      if (streams.spend.form.value?.symbol == null ||
          streams.spend.form.value?.symbol == 'RVN' ||
          streams.spend.form.value?.symbol == 'Ravencoin') {
        streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          symbol: pros.balances.first.security.symbol,
        ));
      }
    }

    /// #612
    //sendAsset.text = sendAsset.text == ''
    //    ? (pros.balances.primaryIndex
    //                .getOne(Current.walletId, pros.securities.currentCurrency) !=
    //            null
    //        ? 'Ravencoin'
    //        : pros.balances.first.security.symbol)
    //    : sendAsset.text;
    sendAsset.text = sendAsset.text == '' ? 'Ravencoin' : sendAsset.text;
    sendFee.text = sendFee.text == '' ? 'Standard' : sendFee.text;
    //sendAssetFocusNode.addListener(refresh);
    //sendAddressFocusNode.addListener(refresh);
    //sendAmountFocusNode.addListener(refresh);
    //sendFeeFocusNode.addListener(refresh);
    //sendMemoFocusNode.addListener(refresh);
    //sendNoteFocusNode.addListener(refresh);
    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if (value != null) {
        if (spendForm != value) {
          spendForm = value;
          var asset = (value.symbol ?? pros.securities.currentCurrency.symbol);
          asset = (asset == pros.securities.currentCurrency.symbol ||
                  asset == 'Ravencoin')
              ? 'Ravencoin'
              : Current.holdingNames.contains(asset)
                  ? asset
                  : asset == ''
                      ? 'Ravencoin'
                      : asset;
          var sendFeeText = value.fee ?? 'Standard';
          var sendNoteText = value.note ?? sendNote.text;
          var sendAddressText = value.address ?? sendAddress.text;
          var addressNameText = value.addressName ?? addressName;
          if (sendAsset.text != asset ||
              sendFee.text != sendFeeText ||
              sendNote.text != sendNoteText ||
              sendAddress.text != sendAddressText ||
              addressName != addressNameText ||
              (asDouble(sendAmount.text) != value.amount)) {
            setState(() {
              sendAsset.text = asset;
              sendFee.text = sendFeeText;
              sendNote.text = sendNoteText;
              sendAddress.text = sendAddressText;
              addressName = addressNameText;
              var x = asDouble(sendAmount.text);
              if (value.amount == null && x > 0) {
                sendAmount.text = '';
                streams.spend.form.add(SpendForm.merge(
                    form: streams.spend.form.value,
                    amount: 0.0,
                    symbol: sendAsset.text,
                    fee: sendFee.text,
                    note: sendNote.text,
                    address: sendAddress.text,
                    addressName: addressName));
              } else if (value.amount != null && x != value.amount) {
                sendAmount.text =
                    value.amount == 0.0 ? '' : value.amount.toString();
                streams.spend.form.add(SpendForm.merge(
                    form: streams.spend.form.value,
                    amount: value.amount ?? 0,
                    symbol: sendAsset.text,
                    fee: sendFee.text,
                    note: sendNote.text,
                    address: sendAddress.text,
                    addressName: addressName));
              } else {
                streams.spend.form.add(SpendForm.merge(
                    form: streams.spend.form.value,
                    amount: value.amount ?? 0,
                    symbol: sendAsset.text,
                    fee: sendFee.text,
                    note: sendNote.text,
                    address: sendAddress.text,
                    addressName: addressName));
              }
            });
          }
        }
      }
    }));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    //sendAssetFocusNode.removeListener(refresh);
    //sendAddressFocusNode.removeListener(refresh);
    //sendAmountFocusNode.removeListener(refresh);
    //sendFeeFocusNode.removeListener(refresh);
    //sendMemoFocusNode.removeListener(refresh);
    //sendNoteFocusNode.removeListener(refresh);
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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  void refresh() => setState(() {});

  void handlePopulateFromQR(String code) {
    var qrData = populateFromQR(
      code: code,
      holdings: Current.holdingNames,
      currentSymbol: data['symbol'],
    );
    if (qrData.address != null) {
      sendAddress.text = qrData.address!;
      if (qrData.addressName != null) {
        addressName = qrData.addressName!;
      }
      if (qrData.amount != null) {
        sendAmount.text = qrData.amount!;
      }
      if (qrData.note != null) {
        sendNote.text = qrData.note!;
      }
      data['symbol'] = qrData.symbol;
      if (!['', null].contains(data['symbol'])) {
        streams.spend.form.add(SpendForm.merge(
          form: streams.spend.form.value,
          symbol: data['symbol'],
        ));
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    minHeight =
        minHeight ?? 1 - (201 + 16) / MediaQuery.of(context).size.height;
    data = populateData(context, data);
    var symbol = streams.spend.form.value?.symbol ??
        pros.securities.currentCurrency.symbol;
    symbol =
        symbol == 'Ravencoin' ? pros.securities.currentCurrency.symbol : symbol;
    security = pros.securities.primaryIndex.getOne(
        symbol,
        symbol == 'RVN' && pros.settings.chain == Chain.ravencoin ||
                symbol == 'EVR' && pros.settings.chain == Chain.evrmore
            ? SecurityType.crypto
            : SecurityType.asset,
        pros.settings.chain,
        pros.settings.net)!;
    useWallet = data.containsKey('walletId') && data['walletId'] != null;
    if (data.containsKey('qrCode')) {
      handlePopulateFromQR(data['qrCode']);
      data.remove('qrCode');
    }
    divisibility = pros.assets.primaryIndex
            .getOne(symbol, security.chain, security.net)
            ?.divisibility ??
        8;
    var possibleHoldings = [
      for (var balance in Current.holdings)
        if (balance.security.symbol == symbol) utils.satToAmount(balance.value)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          utils.amountToSat(double.parse(visibleAmount)),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), child: body());
  }

  Widget body() => BackdropLayers(
        backAlignment: Alignment.bottomCenter,
        frontAlignment: Alignment.topCenter,
        front: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            CoinSpec(
                pageTitle: 'Send',
                security: security,
                color: Theme.of(context).backgroundColor),
            FrontCurve(fuzzyTop: false, height: 8, frontLayerBoxShadow: [
              BoxShadow(
                  color: const Color(0x33000000),
                  offset: Offset(0, -2),
                  blurRadius: 3),
              BoxShadow(
                  color: const Color(0xFFFFFFFF),
                  offset: Offset(0, 2),
                  blurRadius: 1),
              BoxShadow(
                  color: const Color(0x1FFFFFFF),
                  offset: Offset(0, 3),
                  blurRadius: 2),
              BoxShadow(
                  color: const Color(0x3DFFFFFF),
                  offset: Offset(0, 4),
                  blurRadius: 4),
            ]),
          ],
        ),
        back: content(scrollController),
      );

  Widget content(ScrollController scrollController) => Container(
      color: AppColors.white,
      child: Stack(
        children: [
          ListView(
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
            children: <Widget>[
              SizedBox(height: 8),
              if (Platform.isIOS) SizedBox(height: 8),
              Container(height: 201),
              SizedBox(height: 8),
              sendAssetField,
              SizedBox(height: 16),
              //toName,
              sendAddressField,
              SizedBox(height: 16),
              sendAmountField,
              SizedBox(height: 16),
              sendFeeField,
              SizedBox(height: 16),
              sendMemoField,
              SizedBox(height: 16),
              sendNoteField,
              SizedBox(height: 8),
              SizedBox(height: 56),
              SizedBox(height: 16),
            ],
          ),
          KeyboardHidesWidgetWithDelay(
              child: components.buttons.layeredButtons(
            context,
            buttons: [sendTransactionButton(disabled: !allValidation())],
            widthSpacer: SizedBox(width: 16),
          ))
        ],
      ));

  Widget get sendAssetField => TextFieldFormatted(
        focusNode: sendAssetFocusNode,
        controller: sendAsset,
        readOnly: true,
        textInputAction: TextInputAction.next,
        decoration: components.styles.decorations.textField(context,
            focusNode: sendAssetFocusNode,
            labelText: 'Asset',
            hintText: 'Ravencoin',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: _produceAssetModal,
            )),
        onTap: () {
          _produceAssetModal();
          setState(() {});
        },
        onEditingComplete: () async {
          FocusScope.of(context).requestFocus(sendAddressFocusNode);
        },
      );

  Widget get toName =>
      Visibility(visible: addressName != '', child: Text('To: $addressName'));

  Widget get sendAddressField => TextFieldFormatted(
        focusNode: sendAddressFocusNode,
        controller: sendAddress,
        textInputAction: TextInputAction.next,
        autocorrect: false,
        inputFormatters: [
          FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'), allow: true)
        ],
        labelText: 'To',
        hintText: 'Address',
        errorText: sendAddress.text != '' && !_validateAddress(sendAddress.text)
            ? 'Unrecognized Address'
            : null,
        onChanged: (value) {
          /// just always put it in
          //if (_validateAddressColor(value)) {
          streams.spend.form.add(SpendForm.merge(
            form: streams.spend.form.value,
            symbol: sendAsset.text,
            fee: sendFee.text,
            address: value,
          ));
          //}
        },
        onEditingComplete: () {
          /// just always put it in
          //if (_validateAddressColor(sendAddress.text)) {
          streams.spend.form.add(SpendForm.merge(
            form: streams.spend.form.value,
            symbol: sendAsset.text,
            fee: sendFee.text,
            address: sendAddress.text,
          ));
          //}
          FocusScope.of(context).requestFocus(sendAmountFocusNode);
          setState(() {});
        },
      );

  Widget get sendAmountField => TextFieldFormatted(
        focusNode: sendAmountFocusNode,
        controller: sendAmount,
        textInputAction: TextInputAction.next,
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: <TextInputFormatter>[
          //DecimalTextInputFormatter(decimalRange: divisibility)
          FilteringTextInputFormatter(RegExp(r'[.0-9]'), allow: true)
        ],
        labelText: 'Amount',
        hintText: 'Quantity',
        errorText: sendAmount.text == ''
            ? null
            //: sendAmount.text.split('.').length > 1
            //    ? 'invalid number'
            : sendAmount.text == '0.0'
                ? 'must be greater than 0'
                : asDouble(sendAmount.text) > holding
                    ? 'too large'
                    : (String x) {
                        if (x.isNumeric) {
                          var y = x.toNum();
                          if (y != null && y.isRVNAmount) {
                            return true;
                          }
                        }
                        return false;
                      }(sendAmount.text)
                        ? null
                        : 'Unrecognized Amount',
        // put ability to put it in as USD here
        /* // functionality has been moved to header
                    suffixText: sendAll ? "don't send all" : 'send all',
                    suffixStyle: Theme.of(context).textTheme.caption,
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
                        verifyVisibleAmount(sendAmount.text);
                      },
                    ),
                    */
        onChanged: (value) {
          if (asDouble(value) > holding) {
            value = holding.toString();
            sendAmount.text = holding.toString();
          }
          visibleAmount = verifyVisibleAmount(value);
          streams.spend.form.add(SpendForm.merge(
            form: streams.spend.form.value,
            symbol: sendAsset.text,
            fee: sendFee.text,
            amount: asDouble(visibleAmount),
          ));
        },
        onEditingComplete: () {
          //sendAmount.text = cleanDecAmount(
          //  sendAmount.text,
          //  zeroToBlank: true,
          //);
          sendAmount.text =
              enforceDivisibility(sendAmount.text, divisibility: divisibility);
          visibleAmount = verifyVisibleAmount(sendAmount.text);
          streams.spend.form.add(SpendForm.merge(
            form: streams.spend.form.value,
            symbol: sendAsset.text,
            fee: sendFee.text,
            amount: asDouble(visibleAmount),
          ));
          //// causes error on ios. as the keyboard becomes dismissed the bottom modal sheet is attempting to appear, they collide.
          //FocusScope.of(context).requestFocus(sendFeeFocusNode);
          FocusScope.of(context).unfocus();
          setState(() {});
        },
      );

  double asDouble(String visibleAmount) =>
      ['', '.'].contains(visibleAmount) ? 0 : double.parse(visibleAmount);

  Widget get sendFeeField => TextFieldFormatted(
        onTap: () {
          _produceFeeModal();
          setState(() {});
        },
        focusNode: sendFeeFocusNode,
        controller: sendFee,
        readOnly: true,
        textInputAction: TextInputAction.next,
        labelText: 'Transaction Speed',
        hintText: 'Standard',
        suffixIcon: IconButton(
            icon: Padding(
                padding: EdgeInsets.only(right: 14),
                child:
                    Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
            onPressed: () {
              _produceFeeModal();
              setState(() {});
            }),
        onChanged: (String? newValue) {
          feeGoal = {
                'Cheap': ravencoin.TxGoals.cheap,
                'Standard': ravencoin.TxGoals.standard,
                'Fast': ravencoin.TxGoals.fast,
              }[newValue] ??
              ravencoin.TxGoals.standard;
          FocusScope.of(context).requestFocus(sendMemoFocusNode);
          setState(() {});
        },
      );

  Widget get sendMemoField => TextFieldFormatted(
      onTap: () async {
        clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
        setState(() {});
      },
      focusNode: sendMemoFocusNode,
      controller: sendMemo,
      textInputAction: TextInputAction.next,
      labelText: 'Memo',
      hintText: 'IPFS',
      helperText:
          sendMemoFocusNode.hasFocus ? 'will be saved on the blockchain' : null,
      helperStyle: Theme.of(context)
          .textTheme
          .caption!
          .copyWith(height: .7, color: AppColors.primary),
      errorText: verifyMemo() ? null : 'too long',
      suffixIcon: clipboard.isAssetData || clipboard.isIpfs
          ? IconButton(
              icon: Icon(Icons.paste_rounded, color: AppColors.black60),
              onPressed: () async {
                sendMemo.text =
                    (await Clipboard.getData('text/plain'))?.text ?? '';
              })
          : null,
      onChanged: (value) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(sendNoteFocusNode);
        setState(() {});
      });

  Widget get sendNoteField => TextFieldFormatted(
      onTap: () async {
        clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
        setState(() {});
      },
      focusNode: sendNoteFocusNode,
      controller: sendNote,
      textInputAction: TextInputAction.next,
      labelText: 'Note',
      hintText: 'Purchase',
      helperText:
          sendNoteFocusNode.hasFocus ? 'will be saved to your phone' : null,
      helperStyle: Theme.of(context)
          .textTheme
          .caption!
          .copyWith(height: .7, color: AppColors.primary),
      suffixIcon: clipboard == '' ||
              clipboard.isIpfs ||
              clipboard.isAddressRVN ||
              clipboard.isAddressRVNt
          ? null
          : IconButton(
              icon: Icon(Icons.paste_rounded, color: AppColors.black60),
              onPressed: () async {
                sendNote.text =
                    (await Clipboard.getData('text/plain'))?.text ?? '';
              },
            ),
      onChanged: (value) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(previewFocusNode);
        setState(() {});
      });

  bool _validateAddress([String? address]) =>
      sendAddress.text == '' ||
      (pros.settings.net == Net.main
          ? sendAddress.text.isAddressRVN
          : sendAddress.text.isAddressRVNt);

  // ignore: unused_element
  bool _validateAddressColor([String? address]) {
    var old = validatedAddress;
    validatedAddress = _validateAddress(address ?? sendAddress.text);
    if (old != validatedAddress) setState(() => {});
    return validatedAddress;
  }

  String verifyVisibleAmount(String value) {
    var amount = cleanDecAmount(value);
    try {
      if (value != '') {
        value = double.parse(value).toString();
      }
    } catch (e) {
      value = value;
    }
    if (amount == '0' || amount != value) {
    } else {
      // todo: estimate fee
      if (amount != '' && double.parse(amount) <= holding) {
      } else {}
    }
    //setState(() => {});
    return amount;
  }

  bool verifyMemo([String? memo]) =>
      (memo ?? sendMemo.text).isMemo || (memo ?? sendMemo.text).isIpfs;

  bool fieldValidation() {
    return sendAddress.text != '' && _validateAddress() && verifyMemo();
  }

  bool holdingValidation() {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    if (sendAmount.text == '') {
      return false;
    } else {
      return holding >= double.parse(sendAmount.text);
    }
  }

  bool allValidation() {
    return rvnValidation() && fieldValidation() && holdingValidation();
  }

  void startSend() {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    var vAddress = sendAddress.text != '' && _validateAddress();
    var vMemo = verifyMemo();
    visibleAmount = verifyVisibleAmount(sendAmount.text);
    if (vAddress && vMemo) {
      FocusScope.of(context).unfocus();
      var sendAmountAsSats = utils.textAmountToSat(sendAmount.text);
      if (holding >= double.parse(sendAmount.text)) {
        var sendRequest = SendRequest(
          sendAll: holding == visibleAmount.toDouble(),
          wallet: Current.wallet,
          sendAddress: sendAddress.text,
          holding: holding,
          visibleAmount: visibleAmount,
          sendAmountAsSats: sendAmountAsSats,
          feeGoal: feeGoal,
          security: sendAsset.text == 'Ravencoin'
              ? null
              : pros.securities.primaryIndex.getOne(
                  sendAsset.text,
                  SecurityType.asset,
                  pros.settings.chain,
                  pros.settings.net,
                ),
          assetMemo: sendAsset.text != 'Ravencoin' &&
                  sendMemo.text != '' &&
                  sendMemo.text.isIpfs
              ? sendMemo.text
              : null,
          //TODO: Currently memos are only for non-asset transactions
          memo: sendAsset.text == 'Ravencoin' &&
                  sendMemo.text != '' &&
                  verifyMemo(sendMemo.text)
              ? sendMemo.text
              : null,
          note: sendNote.text != '' ? sendNote.text : null,
        );
        confirmSend(sendRequest);
      }
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate proclaim? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....
  Widget sendTransactionButton({bool disabled = false}) =>
      components.buttons.actionButton(
        context,
        focusNode: previewFocusNode,
        enabled: !disabled && !clicked,
        label: !clicked ? 'Preview' : 'Generating Transaction...',
        onPressed: () {
          setState(() {
            clicked = true;
          });
          startSend();
        },
        disabledOnPressed: () {
          if (!rvnValidation()) {
            tellUserNoRVN();
          }
        },
      );

  void confirmSend(SendRequest sendRequest) {
    streams.spend.make.add(sendRequest);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          symbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
                  ? pros.securities.currentCurrency.symbol
                  : streams.spend.form.value?.symbol) ??
              pros.securities.currentCurrency.symbol),
          displaySymbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
                  ? 'Ravencoin'
                  : streams.spend.form.value?.symbol) ??
              'Ravencoin'),
          subSymbol: '',
          paymentSymbol: pros.securities.currentCurrency.symbol,
          items: [
            ['To', sendAddress.text],
            if (addressName != '') ['Known As', addressName],
            [
              'Amount',
              sendRequest.sendAll ? 'calculating amount...' : visibleAmount
            ],
            if (sendMemo.text != '') ['Memo', sendMemo.text],
            if (sendNote.text != '') ['Note', sendNote.text],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () => streams.spend.send.add(streams.spend.made.value),
          buttonWord: 'Send',
          loadingMessage: 'Sending',
        )
      },
    );
    setState(() {
      clicked = false;
    });
  }

  void _produceAssetModal() {
    final tail = Current.holdingNames
        .where((item) => item != pros.securities.currentCurrency.symbol)
        .toList();
    final head = Current.holdingNames
        .where((item) => item == pros.securities.currentCurrency.symbol)
        .toList();
    SelectionItems(context, modalSet: SelectionSet.Holdings)
        .build(holdingNames: head + tail);
  }

  void _produceFeeModal() {
    SelectionItems(context, modalSet: SelectionSet.Fee).build();
  }
}
