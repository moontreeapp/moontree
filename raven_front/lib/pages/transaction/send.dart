import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_front/backdrop/backdrop.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/utils/qrcode.dart';

import 'package:raven_front/widgets/bottom/selection_items.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:barcode_scan2/barcode_scan2.dart';

import 'package:raven_back/streams/spend.dart';
import 'package:raven_back/services/transaction/fee.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/raven_back.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/utils/address.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_front/utils/data.dart';
import 'package:raven_front/theme/extensions.dart';

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
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';
  bool useWallet = false;
  double holding = 0.0;
  FocusNode sendAddressFocusNode = FocusNode();
  FocusNode sendAmountFocusNode = FocusNode();
  FocusNode sendFeeFocusNode = FocusNode();
  FocusNode sendMemoFocusNode = FocusNode();
  FocusNode sendNoteFocusNode = FocusNode();
  TxGoal feeGoal = standard;
  bool sendAll = false;
  String addressName = '';

  @override
  void initState() {
    super.initState();
    sendAsset.text = sendAsset.text == '' ? 'Ravencoin' : sendAsset.text;
    listeners.add(streams.spend.form.listen((SpendForm? value) {
      if ((SpendForm.merge(form: spendForm, amount: 0.0) !=
          SpendForm.merge(form: value, amount: 0.0))) {
        setState(() {
          spendForm = value;
          var asset = (value?.symbol ?? 'RVN');
          sendAsset.text = asset == 'RVN' || asset == 'Ravencoin'
              ? 'Ravencoin'
              : Current.holdingNames.contains(asset)
                  ? asset
                  : sendAsset.text == ''
                      ? 'Ravencoin'
                      : sendAsset.text;
          sendFee.text = value?.fee ?? 'Standard';
          sendNote.text = value?.note ?? sendNote.text;
          sendAmount.text = value?.amount?.toString() ?? sendAmount.text;
          sendAddress.text = value?.address ?? sendAddress.text;
          addressName = value?.addressName ?? addressName;
        });
      }
    }));
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
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
          utils.amountToSat(double.parse(visibleAmount),
              divisibility: divisibility),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return body();
  }

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

  bool _validateAddress([String? address]) =>
      sendAddress.text == '' ||
      rvnCondition(address ?? sendAddress.text, net: res.settings.net);

  bool _validateAddressColor([String? address]) {
    var old = validatedAddress;
    validatedAddress = validateAddressType(address ?? sendAddress.text);
    if (validatedAddress != '') {
      if ((validatedAddress == 'RVN' && res.settings.net == Net.Main) ||
          (validatedAddress == 'RVNt' && res.settings.net == Net.Test)) {
        //} else if (validatedAddress == 'UNS') {
        //} else if (validatedAddress == 'ASSET') {
      }
      if (old != validatedAddress) setState(() => {});
      return true;
    }
    if (old != '') setState(() => {});
    return false;
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
      if (double.parse(amount) <= holding) {
      } else {}
    }
    //setState(() => {});
    return amount;
  }

  bool verifyMemo([String? memo]) => (memo ?? sendMemo.text).length <= 80;

  Widget body() => Padding(
      padding: EdgeInsets.only(top: 16, left: 16, right: 16, bottom: 40),
      // solves scrolling while keyboard
      child: CustomScrollView(
        shrinkWrap: true,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // list items
                //Text(useWallet ? 'Use Wallet: ' + data['walletId'] : '',
                //    style: Theme.of(context).textTheme.caption),
                //;
                TextField(
                  controller: sendAsset,
                  readOnly: true,
                  decoration: components.styles.decorations.textFeild(context,
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
                ),
                SelectableText(
                  'Select me custom menu',
                  selectionControls: CustomToolBar(),
                ),
                SizedBox(height: 16.0),
                Visibility(
                    visible: addressName != '',
                    child: Text('To: $addressName')),
                TextField(
                  focusNode: sendAddressFocusNode,
                  controller: sendAddress,
                  autocorrect: false,
                  decoration: components.styles.decorations.textFeild(
                    context,
                    labelText: 'To',
                    hintText: 'Address',
                    errorText: !_validateAddress(sendAddress.text)
                        ? 'Unrecognized Address'
                        : null,
                    suffixIcon:
                        QRCodeButton(pageTitle: 'Send-to', light: false),
                  ),
                  //suffixIcon: IconButton(
                  //  icon:
                  //      Icon(MdiIcons.qrcodeScan, color: Color(0xDE000000)),
                  //  onPressed: () async {
                  //    ScanResult result = await BarcodeScanner.scan();
                  //    switch (result.type) {
                  //      case ResultType.Barcode:
                  //        populateFromQR(result.rawContent);
                  //        break;
                  //      case ResultType.Error:
                  //        ScaffoldMessenger.of(context).showSnackBar(
                  //          SnackBar(content: Text(result.rawContent)),
                  //        );
                  //        break;
                  //      case ResultType.Cancelled:
                  //        // no problem, don't do anything
                  //        break;
                  //    }
                  //  },
                  //)),
                  onChanged: (value) {
                    _validateAddressColor(value);
                  },
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(sendAmountFocusNode);
                  },
                ),

                SizedBox(height: 16.0),
                TextField(
                  readOnly: sendAll,
                  focusNode: sendAmountFocusNode,
                  controller: sendAmount,
                  keyboardType: TextInputType.number,
                  decoration: components.styles.decorations.textFeild(
                    context,
                    labelText: 'Amount', // Amount -> Amount*
                    hintText: 'Quantity',
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
                  ),
                  onChanged: (value) {
                    visibleAmount = verifyVisibleAmount(value);
                    streams.spend.form.add(SpendForm.merge(
                        form: streams.spend.form.value,
                        amount: double.parse(visibleAmount)));
                  },
                  onEditingComplete: () {
                    sendAmount.text = cleanDecAmount(
                      sendAmount.text,
                      zeroToBlank: true,
                    );
                    sendAmount.text = enforceDivisibility(sendAmount.text,
                        divisibility: divisibility);
                    visibleAmount = verifyVisibleAmount(sendAmount.text);
                    streams.spend.form.add(SpendForm.merge(
                        form: streams.spend.form.value,
                        amount: double.parse(visibleAmount)));
                    FocusScope.of(context).requestFocus(sendFeeFocusNode);
                    setState(() {});
                  },
                ),

                SizedBox(height: 16.0),
                TextField(
                  focusNode: sendFeeFocusNode,
                  controller: sendFee,
                  readOnly: true,
                  decoration: components.styles.decorations.textFeild(context,
                      labelText: 'Fee',
                      hintText: 'Standard',
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
                          'Cheap': cheap,
                          'Standard': standard,
                          'Fast': fast,
                        }[newValue] ??
                        standard; // <--- replace by custom dialogue
                    FocusScope.of(context).requestFocus(sendNoteFocusNode);
                    setState(() {});
                  },
                ),

                /// HIDE MEMO for beta - not supported by ravencoin anyway
                //TextField(
                //    focusNode: sendMemoFocusNode,
                //    controller: sendMemo,
                //    decoration: InputDecoration(
                //        focusedBorder: UnderlineInputBorder(
                //            borderSide: BorderSide(color: memoColor)),
                //        enabledBorder: UnderlineInputBorder(
                //            borderSide: BorderSide(color: memoColor)),
                //        border: UnderlineInputBorder(),
                //        labelText: 'Memo (optional)',
                //        hintText: 'IPFS hash publicly posted on transaction'),
                //    onChanged: (value) {
                //      var oldMemoColor = memoColor;
                //      memoColor = verifyMemo(value)
                //          ? Theme.of(context).good!
                //          : Theme.of(context).bad!;
                //      if (value == '') {
                //        memoColor = Colors.grey.shade400;
                //      }
                //      if (oldMemoColor != memoColor) {
                //        setState(() {});
                //      }
                //    },
                //    onEditingComplete: () {
                //      FocusScope.of(context).requestFocus(sendNoteFocusNode);
                //      setState(() {});
                //    }),
                SizedBox(height: 16.0),
                TextField(
                  focusNode: sendNoteFocusNode,
                  controller: sendNote,
                  decoration: components.styles.decorations.textFeild(context,
                      labelText: 'Note', hintText: 'Private note to self'),
                ),
                SizedBox(height: 16.0),
              ],
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Row(children: [
              allValidation()
                  ? sendTransactionButton()
                  : sendTransactionButton(disabled: true)
            ]),
          ),
        ],
      ));

  bool fieldValidation() {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
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
      var sendAmountAsSats = utils.amountToSat(
        double.parse(sendAmount.text),
        divisibility: divisibility,
      );
      if (holding >= double.parse(sendAmount.text)) {
        var sendRequest = SendRequest(
            sendAll: sendAll,
            wallet: Current.wallet,
            sendAddress: sendAddress.text,
            holding: holding,
            visibleAmount: visibleAmount,
            sendAmountAsSats: sendAmountAsSats,
            feeGoal: feeGoal);
        confirmSend(sendRequest);
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) =>
                AlertDialog(
                    title: Text('Unable to Create Transaction'),
                    content:
                        Text('Send Amount is larger than account holding.'),
                    actions: [
                      TextButton(
                          child: Text('Ok'),
                          onPressed: () => Navigator.pop(context))
                    ]));
      }
    } else {
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: Text('Unable to Create Transaction'),
                  content: Text((!vAddress
                          ? 'Invalid Address: please double check.\n'
                          : '') +
                      (!vMemo
                          ? 'Invalid Memo: Must not exceed 80 characters.'
                          : '')),
                  actions: [
                    TextButton(
                        child: Text('Ok'),
                        onPressed: () => Navigator.pop(context))
                  ]));
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
            if (sendNote.text != '') ['Note', sendNote.text],
            if (sendMemo.text != '') ['Memo', sendMemo.text]
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () =>
              // will this execute the values here or there?
              streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
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
