import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_front/pages/misc/checkout.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/qrcode.dart';
import 'package:raven_front/utils/transformers.dart';

import 'package:raven_front/widgets/widgets.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

import 'package:raven_back/streams/spend.dart';
import 'package:raven_back/services/transaction/maker.dart';
import 'package:raven_back/raven_back.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_front/utils/data.dart';

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

  @override
  void initState() {
    super.initState();
    //minHeight = 1 - (201 + 16) / MediaQuery.of(context).size.height;
    sendAsset.text = sendAsset.text == '' ? 'Ravencoin' : sendAsset.text;
    sendFee.text = sendFee.text == '' ? 'Standard' : sendAsset.text;
    //sendAssetFocusNode.addListener(refresh);
    //sendAddressFocusNode.addListener(refresh);
    //sendAmountFocusNode.addListener(refresh);
    //sendFeeFocusNode.addListener(refresh);
    //sendMemoFocusNode.addListener(refresh);
    //sendNoteFocusNode.addListener(refresh);
    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if (value != null) {
        print('');
        print(spendForm);
        print(value);
        if (spendForm != value) {
          spendForm = value;
          var asset = (value.symbol ?? res.securities.RVN.symbol);
          asset = (asset == res.securities.RVN.symbol || asset == 'Ravencoin')
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
              addressName != addressNameText) {
            setState(() {
              sendAsset.text = asset;
              sendFee.text = sendFeeText;
              sendNote.text = sendNoteText;
              sendAddress.text = sendAddressText;
              addressName = addressNameText;
              var x = asDouble(sendAmount.text);
              print('\n$x vs ${value.amount}');
              if (value.amount == null && x > 0) {
                print('blanking');
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
                print('setting to ${value.amount}');
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
    var symbol = streams.spend.form.value?.symbol ?? res.securities.RVN.symbol;
    symbol = symbol == 'Ravencoin' ? res.securities.RVN.symbol : symbol;
    security = res.securities.bySymbol.getAll(symbol).first;
    useWallet = data.containsKey('walletId') && data['walletId'] != null;
    if (data.containsKey('qrCode')) {
      handlePopulateFromQR(data['qrCode']);
      data.remove('qrCode');
    }
    divisibility = res.assets.bySymbol.getOne(symbol)?.divisibility ?? 8;
    var possibleHoldings = [
      for (var balance in Current.holdings)
        if (balance.security.symbol == symbol)
          utils.satToAmount(balance.confirmed)
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
            padding: EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 0),
            children: <Widget>[
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

  Widget get sendAssetField => TextField(
        focusNode: sendAssetFocusNode,
        controller: sendAsset,
        readOnly: true,
        decoration: components.styles.decorations.textField(context,
            focusNode: sendAssetFocusNode,
            labelText: 'Asset',
            hintText: 'Ravencoin',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => _produceAssetModal(),
            )),
        onTap: () {
          _produceAssetModal();
        },
        onEditingComplete: () async {
          FocusScope.of(context).requestFocus(sendAddressFocusNode);
        },
      );

  Widget get toName =>
      Visibility(visible: addressName != '', child: Text('To: $addressName'));

  Widget get sendAddressField => TextField(
        focusNode: sendAddressFocusNode,
        controller: sendAddress,
        textInputAction: TextInputAction.done,
        autocorrect: false,
        inputFormatters: [
          FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'), allow: true)
        ],
        decoration: components.styles.decorations.textField(
          context,
          focusNode: sendAddressFocusNode,
          labelText: 'To',
          hintText: 'Address',
          errorText:
              sendAddress.text != '' && !_validateAddress(sendAddress.text)
                  ? 'Unrecognized Address'
                  : null,
        ),
        onChanged: (value) {
          if (_validateAddressColor(value)) {
            streams.spend.form.add(SpendForm.merge(
                form: streams.spend.form.value, address: value));
          }
        },
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(sendAmountFocusNode);
          setState(() {});
          if (_validateAddressColor(sendAddress.text)) {
            streams.spend.form.add(SpendForm.merge(
                form: streams.spend.form.value, address: sendAddress.text));
          }
        },
      );

  Widget get sendAmountField => TextField(
        focusNode: sendAmountFocusNode,
        controller: sendAmount,
        textInputAction: TextInputAction.done,
        keyboardType:
            TextInputType.numberWithOptions(decimal: true, signed: false),
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: divisibility)
        ],
        decoration: components.styles.decorations.textField(
          context,
          focusNode: sendAmountFocusNode,
          labelText: 'Amount',
          hintText: 'Quantity',
          errorText: sendAmount.text == ''
              ? null
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
        ),
        onChanged: (value) {
          if (asDouble(value) > holding) {
            value = holding.toString();
            sendAmount.text = holding.toString();
          }
          visibleAmount = verifyVisibleAmount(value);
          streams.spend.form.add(SpendForm.merge(
              form: streams.spend.form.value, amount: asDouble(visibleAmount)));
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
              form: streams.spend.form.value, amount: asDouble(visibleAmount)));
          FocusScope.of(context).requestFocus(sendFeeFocusNode);
          setState(() {});
        },
      );

  double asDouble(String visibleAmount) =>
      visibleAmount == '' ? 0 : double.parse(visibleAmount);

  Widget get sendFeeField => TextField(
        focusNode: sendFeeFocusNode,
        controller: sendFee,
        readOnly: true,
        decoration: components.styles.decorations.textField(context,
            labelText: 'Transaction Speed',
            hintText: 'Standard',
            focusNode: sendFeeFocusNode,
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => _produceFeeModal(),
            )),
        onTap: () {
          _produceFeeModal();
        },
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

  Widget get sendMemoField => TextField(
      onTap: () async {
        clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
      },
      focusNode: sendMemoFocusNode,
      controller: sendMemo,
      decoration: components.styles.decorations.textField(
        context,
        focusNode: sendMemoFocusNode,
        labelText: 'Memo',
        hintText: 'IPFS',
        helperText: sendMemoFocusNode.hasFocus
            ? 'will be saved on the blockchain'
            : null,
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
      ),
      onChanged: (value) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(sendNoteFocusNode);
        setState(() {});
      });

  Widget get sendNoteField => TextField(
      onTap: () async {
        clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
      },
      focusNode: sendNoteFocusNode,
      controller: sendNote,
      decoration: components.styles.decorations.textField(context,
          focusNode: sendNoteFocusNode,
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
                )),
      onChanged: (value) {
        setState(() {});
      },
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(previewFocusNode);
        setState(() {});
      });

  bool _validateAddress([String? address]) =>
      sendAddress.text == '' ||
      (res.settings.net == Net.Main
          ? sendAddress.text.isAddressRVN
          : sendAddress.text.isAddressRVNt);

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
    return fieldValidation() && holdingValidation();
  }

  void startSend() {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    var vAddress = sendAddress.text != '' && _validateAddress();
    var vMemo = verifyMemo();
    visibleAmount = verifyVisibleAmount(sendAmount.text);
    if (vAddress && vMemo) {
      FocusScope.of(context).unfocus();
      var sendAmountAsSats = utils.amountToSat(double.parse(sendAmount.text));
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
              : res.securities.bySymbolSecurityType
                  .getOne(sendAsset.text, SecurityType.RavenAsset),
          assetMemo: sendAsset.text != 'Ravencoin' &&
                  sendMemo.text != '' &&
                  sendMemo.text.isIpfs
              ? sendMemo.text
              : null,
          memo: sendAsset.text == 'Ravencoin' &&
                  sendMemo.text != '' &&
                  verifyMemo(sendMemo.text)
              ? sendMemo.text
              : !sendMemo.text.isIpfs &&
                      sendMemo.text != '' &&
                      verifyMemo(sendMemo.text)
                  ? sendMemo.text
                  : null,
          note: sendNote.text != '' ? sendNote.text : null,
        );
        print('sendRequest $sendRequest');
        confirmSend(sendRequest);
      }
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate reservoir? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....
  Widget sendTransactionButton({bool disabled = false}) =>
      components.buttons.actionButton(
        context,
        focusNode: previewFocusNode,
        enabled: !disabled,
        onPressed: () => startSend(),
      );

  void confirmSend(SendRequest sendRequest) {
    streams.spend.make.add(sendRequest);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          symbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
                  ? res.securities.RVN.symbol
                  : streams.spend.form.value?.symbol) ??
              res.securities.RVN.symbol),
          displaySymbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
                  ? 'Ravencoin'
                  : streams.spend.form.value?.symbol) ??
              'Ravencoin'),
          subSymbol: '',
          paymentSymbol: res.securities.RVN.symbol,
          items: [
            ['To', sendAddress.text],
            if (addressName != '') ['Known As', addressName],
            ['Amount', visibleAmount],
            if (sendMemo.text != '') ['Memo', sendMemo.text],
            if (sendNote.text != '') ['Note', sendNote.text],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () =>
              // will this execute the values here or there?
              streams.spend.send.add(streams.spend.made.value),
          buttonWord: 'Send',
          loadingMessage: 'Sending',
        )
      },
    );
  }

  void _produceAssetModal() {
    var options = Current.holdingNames.where((item) => item != 'RVN').toList();
    SelectionItems(context, modalSet: SelectionSet.Holdings).build(
        holdingNames: options.isNotEmpty
            ? ['Ravencoin'] + options
            : ['Ravencoin', 'Amazon']);
  }

  void _produceFeeModal() {
    SelectionItems(context, modalSet: SelectionSet.Fee).build();
  }
}
