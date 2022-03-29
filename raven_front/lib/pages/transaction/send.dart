import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/qrcode.dart';

import 'package:raven_front/widgets/widgets.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;

import 'package:raven_back/streams/spend.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/raven_back.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/address.dart';
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
    sendAsset.text = sendAsset.text == '' ? 'Ravencoin' : sendAsset.text;
    sendFee.text = sendFee.text == '' ? 'Standard' : sendAsset.text;
    sendAssetFocusNode.addListener(refresh);
    sendAddressFocusNode.addListener(refresh);
    sendAmountFocusNode.addListener(refresh);
    sendFeeFocusNode.addListener(refresh);
    sendMemoFocusNode.addListener(refresh);
    sendNoteFocusNode.addListener(refresh);

    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if (value != null) {
        //if ((SpendForm.merge(form: spendForm, amount: 0.0) !=
        //    SpendForm.merge(form: value, amount: 0.0))) {
        setState(() {
          spendForm = value;
          var asset = (value.symbol ?? 'RVN');
          sendAsset.text = asset == 'RVN' || asset == 'Ravencoin'
              ? 'Ravencoin'
              : Current.holdingNames.contains(asset)
                  ? asset
                  : sendAsset.text == ''
                      ? 'Ravencoin'
                      : sendAsset.text;
          sendFee.text = value.fee ?? 'Standard';
          sendNote.text = value.note ?? sendNote.text;
          sendAmount.text = value.amount == 0.0
              ? ''
              : value.amount?.toString() ?? sendAmount.text;
          sendAddress.text = value.address ?? sendAddress.text;
          addressName = value.addressName ?? addressName;
        });
      }
    }));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sendAssetFocusNode.removeListener(refresh);
    sendAddressFocusNode.removeListener(refresh);
    sendAmountFocusNode.removeListener(refresh);
    sendFeeFocusNode.removeListener(refresh);
    sendMemoFocusNode.removeListener(refresh);
    sendNoteFocusNode.removeListener(refresh);
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
    data = populateData(context, data);
    var symbol = streams.spend.form.value?.symbol ?? 'RVN';
    symbol = symbol == 'Ravencoin' ? 'RVN' : symbol;
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
        onTap: () => FocusScope.of(context).unfocus(),
        // we want this to be liquid as well, #182
        child: body());
  }

  Widget body() => components.page.form(
        context,
        controller: scrollController,
        columnWidgets: <Widget>[
          // list items
          //Text(useWallet ? 'Use Wallet: ' + data['walletId'] : '',
          //    style: Theme.of(context).textTheme.caption),
          //;
          sendAssetField,
          //toName,
          sendAddressField,
          sendAmountField,
          sendFeeField,
          sendMemoField,
          sendNoteField,
        ],
        floatingButtons: [
          //allValidation()
          //?
          sendTransactionButton()
          //: sendTransactionButton(disabled: true)
        ],
      );

  Widget get sendAssetField => TextField(
        focusNode: sendAssetFocusNode,
        controller: sendAsset,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
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
        onTap: () async {
          clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
        },
        selectionControls: NoToolBar(),
        focusNode: sendAddressFocusNode,
        controller: sendAddress,
        autocorrect: false,
        inputFormatters: [
          FilteringTextInputFormatter(RegExp(r'[a-zA-Z0-9]'), allow: true)
        ],
        decoration: components.styles.decorations.textFeild(context,
            focusNode: sendAddressFocusNode,
            labelText: 'To',
            hintText: 'Address',
            errorText:
                sendAddress.text != '' && !_validateAddress(sendAddress.text)
                    ? 'Unrecognized Address'
                    : null,
            suffixIcon: true ||
                    (res.settings.net == Net.Main && clipboard.isAddressRVN) ||
                    (res.settings.net == Net.Test && clipboard.isAddressRVNt)
                ?
                //QRCodeButton(pageTitle: 'Send-to', light: false),
                IconButton(
                    icon: Icon(Icons.paste_rounded, color: AppColors.black60),
                    onPressed: () async {
                      sendAddress.text =
                          (await Clipboard.getData('text/plain'))?.text ?? '';
                    },
                  )
                : null),
        onChanged: (value) {
          _validateAddressColor(value);
        },
        onEditingComplete: () {
          FocusScope.of(context).requestFocus(sendAmountFocusNode);
        },
      );

  Widget get sendAmountField => TextField(
        selectionControls: NoToolBar(),
        focusNode: sendAmountFocusNode,
        controller: sendAmount,
        textInputAction: TextInputAction.done,
        keyboardType: TextInputType.number,
        decoration: components.styles.decorations.textFeild(
          context,
          focusNode: sendAmountFocusNode,
          labelText: 'Amount',
          hintText: 'Quantity',
          errorText: sendAmount.text == ''
              ? null
              : sendAmount.text == '0.0'
                  ? 'must be greater than 0'
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
          //visibleAmount = verifyVisibleAmount(value);
          //streams.spend.form.add(SpendForm.merge(
          //    form: streams.spend.form.value,
          //    amount: double.parse(visibleAmount)));
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
              amount: visibleAmount == '' ? 0 : double.parse(visibleAmount)));
          FocusScope.of(context).requestFocus(sendFeeFocusNode);
          setState(() {});
        },
      );

  //SizedBox(height: 16.0),
  Widget get sendFeeField => TextField(
        focusNode: sendFeeFocusNode,
        controller: sendFee,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
            labelText: 'Transaction Speed',
            hintText: 'Standard',
            focusNode: sendFeeFocusNode,
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      //color: Color(0xFF606060))),
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
      selectionControls: NoToolBar(),
      focusNode: sendMemoFocusNode,
      controller: sendMemo,
      decoration: components.styles.decorations.textFeild(
        context,
        focusNode: sendMemoFocusNode,
        labelText: 'Memo',
        hintText: 'IPFS',
        helperText:
            sendMemoFocusNode.hasFocus ? 'Saved on the blockchain' : null,
        helperStyle: Theme.of(context)
            .textTheme
            .caption!
            .copyWith(height: .7, color: AppColors.primary),
        errorText: verifyMemo() ? null : 'too long',
        suffixIcon: clipboard.isAssetMemo || clipboard.isIpfs
            ? IconButton(
                icon: Icon(Icons.paste_rounded, color: AppColors.black60),
                onPressed: () async {
                  sendNote.text =
                      (await Clipboard.getData('text/plain'))?.text ?? '';
                })
            : null,
      ),
      onChanged: (value) {},
      onEditingComplete: () {
        FocusScope.of(context).requestFocus(sendNoteFocusNode);
        setState(() {});
      });

  Widget get sendNoteField => TextField(
      onTap: () async {
        clipboard = (await Clipboard.getData('text/plain'))?.text ?? '';
      },
      selectionControls: NoToolBar(),
      focusNode: sendNoteFocusNode,
      controller: sendNote,
      decoration: components.styles.decorations.textFeild(context,
          focusNode: sendNoteFocusNode,
          labelText: 'Note',
          hintText: 'Purchase',
          helperText: sendNoteFocusNode.hasFocus ? 'Saved to your phone' : null,
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
      onChanged: (value) {},
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
          // assetMemo: // we don't have a UI field for this.
          // should we use the memo field for assetMemo if sending asset
          // or should always use that field for op return memos??

          // we should use assetMemo on IPFS hashes since assetMemos can only
          // be ipfs or txids. otherwise we should use memo which can be
          // any text up to lenght bytes 80.
          // sendMemo.text.isAssetMemo

          // TODO: Convert text to UInt8Array here to pass on
          assetMemo: sendAsset.text != 'Ravencoin' && sendMemo.text.isIpfs
              ? sendMemo.text
              : null,
          memo: sendAsset.text == 'Ravencoin' &&
                  sendMemo.text != '' &&
                  verifyMemo(sendMemo.text)
              ? sendMemo.text
              : !sendMemo.text.isIpfs && verifyMemo(sendMemo.text)
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
                  ? 'RVN'
                  : streams.spend.form.value?.symbol) ??
              'RVN'),
          displaySymbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
                  ? 'Ravencoin'
                  : streams.spend.form.value?.symbol) ??
              'Ravencoin'),
          subSymbol: '',
          paymentSymbol: 'RVN',
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
