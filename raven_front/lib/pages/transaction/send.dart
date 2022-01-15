import 'dart:async';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'package:raven_front/widgets/bottom/selection_items.dart';
import 'package:raven_front/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:barcode_scan2/barcode_scan2.dart';

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
  bool loading = false;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.app.spending.symbol.listen((value) {
      if (value == 'RVN') {
        value = 'Ravencoin';
      }
      if (sendAsset.text != value) {
        setState(() {
          sendAsset.text = value;
        });
      }
    }));
    listeners.add(streams.app.spending.fee.listen((value) {
      if (sendFee.text != value) {
        setState(() {
          sendFee.text = value;
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
    var symbol = streams.app.spending.symbol.value;
    symbol = symbol == 'Ravencoin' ? 'RVN' : symbol;
    useWallet = data.containsKey('walletId') && data['walletId'] != null;
    if (data.containsKey('qrcode')) populateFromQR(data['qrcode']);
    divisibility = assets.bySymbol.getOne(symbol)?.divisibility ?? 8;
    var possibleHoldings = [
      for (var balance in useWallet
          ? Current.walletHoldings(data['walletId'])
          : Current.holdings)
        if (balance.security.symbol == symbol) satToAmount(balance.confirmed)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          amountToSat(double.parse(visibleAmount), divisibility: divisibility),
          symbol: symbol,
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: loading ? Loader(message: 'Sending Transaction') : body());
  }

  void populateFromQR(String code) {
    if (code.startsWith('raven:')) {
      sendAddress.text = code.substring(6).split('?')[0];
      var params = parseReceiveParams(code);
      if (params.containsKey('amount')) {
        sendAmount.text = cleanDecAmount(params['amount']!);
      }
      if (params.containsKey('label')) {
        sendNote.text = cleanLabel(params['label']!);
      }
      if (params.containsKey('to')) {
        addressName = cleanLabel(params['to']!);
      }
      data['symbol'] = requestedAsset(params,
          holdings: useWallet
              ? Current.walletHoldingNames(data['walletId'])
              : Current.holdingNames,
          current: data['symbol']);
    } else {
      sendAddress.text = code;
    }
  }

  bool _validateAddress([String? address]) =>
      sendAddress.text == '' ||
      rvnCondition(address ?? sendAddress.text, net: Current.account.net);

  bool _validateAddressColor([String? address]) {
    var old = validatedAddress;
    validatedAddress = validateAddressType(address ?? sendAddress.text);
    if (validatedAddress != '') {
      if ((validatedAddress == 'RVN' && Current.account.net == Net.Main) ||
          (validatedAddress == 'RVNt' && Current.account.net == Net.Test)) {
        //} else if (validatedAddress == 'UNS') {
        //} else if (validatedAddress == 'ASSET') {
      }
      if (old != validatedAddress) setState(() => {});
      return true;
    }
    if (old != '') setState(() => {});
    return false;
  }

  void verifyVisibleAmount(String value) {
    visibleAmount = cleanDecAmount(value);
    try {
      value = double.parse(value).toString();
    } catch (e) {
      value = value;
    }
    if (visibleAmount == '0' || visibleAmount != value) {
    } else {
      // todo: estimate fee
      if (double.parse(visibleAmount) <= holding) {
      } else {}
    }
    //setState(() => {});
  }

  bool verifyMemo([String? memo]) => (memo ?? sendMemo.text).length <= 80;

  Widget body() => Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Flexible(
                child: ListView(
              // solves scrolling while keyboard
              shrinkWrap: true,
              padding: EdgeInsets.only(top: 16, left: 16, right: 16),
              children: <Widget>[
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

                SizedBox(height: 16.0),
                Visibility(
                    visible: addressName != '',
                    child: Text('To: $addressName')),
                TextField(
                  focusNode: sendAddressFocusNode,
                  controller: sendAddress,
                  autocorrect: false,
                  decoration: components.styles.decorations.textFeild(context,
                      labelText: 'To',
                      hintText: 'Address',
                      errorText: !_validateAddress(sendAddress.text)
                          ? 'Unrecognized Address'
                          : null,
                      suffixIcon: IconButton(
                        icon:
                            Icon(MdiIcons.qrcodeScan, color: Color(0xDE000000)),
                        onPressed: () async {
                          ScanResult result = await BarcodeScanner.scan();
                          switch (result.type) {
                            case ResultType.Barcode:
                              populateFromQR(result.rawContent);
                              break;
                            case ResultType.Error:
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(result.rawContent)),
                              );
                              break;
                            case ResultType.Cancelled:
                              // no problem, don't do anything
                              break;
                          }
                        },
                      )),
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
                  decoration: components.styles.decorations.textFeild(context,
                      labelText: 'Amount', // Amount -> Amount*
                      hintText: 'Quantity'
                      //suffixText: sendAll ? "don't send all" : 'send all',
                      //suffixStyle: Theme.of(context).textTheme.caption,
                      //suffixIcon: IconButton(
                      //  icon: Icon(
                      //      sendAll ? Icons.not_interested : Icons.all_inclusive,
                      //      color: Color(0xFF606060)),
                      //  onPressed: () {
                      //    if (!sendAll) {
                      //      sendAll = true;
                      //      sendAmount.text = holding.toString();
                      //    } else {
                      //      sendAll = false;
                      //      sendAmount.text = '';
                      //    }
                      //    verifyVisibleAmount(sendAmount.text);
                      //  },
                      //),
                      ),
                  onChanged: (value) {
                    verifyVisibleAmount(value);
                    streams.app.spending.amount
                        .add(double.parse(visibleAmount));
                  },
                  onEditingComplete: () {
                    sendAmount.text = cleanDecAmount(
                      sendAmount.text,
                      zeroToBlank: true,
                    );
                    sendAmount.text = enforceDivisibility(sendAmount.text,
                        divisibility: divisibility);
                    verifyVisibleAmount(sendAmount.text);
                    streams.app.spending.amount
                        .add(double.parse(visibleAmount));
                    FocusScope.of(context).requestFocus(sendFeeFocusNode);
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
                  onEditingComplete: () async => startSend(),
                ),
              ],
            )),
            Padding(
              padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [sendTransactionButton()]),
            ),
          ]);

  Future startSend() async {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    var vAddress = sendAddress.text != '' && _validateAddress();
    var vMemo = verifyMemo();
    if (sendAmount.text != '' && _validateAddress() && verifyMemo()) {
      FocusScope.of(context).unfocus();
      var sendAmountAsSats = amountToSat(
        double.parse(sendAmount.text),
        divisibility: divisibility,
      );
      if (holding >= double.parse(sendAmount.text)) {
        var sendRequest = SendRequest(
            useWallet: useWallet,
            sendAll: sendAll,
            wallet: data['walletId'] != null
                ? Current.wallet(data['walletId'])
                : null,
            account: Current.account,
            sendAddress: sendAddress.text,
            holding: holding,
            visibleAmount: visibleAmount,
            sendAmountAsSats: sendAmountAsSats,
            feeGoal: feeGoal);
        await confirmSend(sendRequest);
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
  Widget sendTransactionButton() => Container(
          child: OutlinedButton.icon(
        onPressed: () async => await startSend(),
        icon: Icon(MdiIcons.arrowTopRightThick),
        label: Text('SEND'.toUpperCase()),
        style: components.styles.buttons.bottom(context),
      ));

  Future confirmSend(SendRequest sendRequest) => showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
              contentPadding: EdgeInsets.all(24.0),
              content: Text('Are you sure you want to send?',
                  style: Theme.of(context).sendConfirm),
              actions: [
                TextButton(
                    child: Text('Cancel'.toUpperCase(),
                        style: Theme.of(context).sendConfirmButton),
                    onPressed: () => Navigator.pop(context)),
                TextButton(
                    child: Text('Send'.toUpperCase(),
                        style: Theme.of(context).sendConfirmButton),
                    onPressed: () {
                      Navigator.pop(context);
                      // temporary test of screen:
                      streams.run.send.add(sendRequest);
                      setState(() => loading = true);
                    })
              ]));

  void _produceAssetModal() {
    var options = (useWallet
            ? Current.walletHoldingNames(data['walletId'])
            : Current.holdingNames)
        .where((item) => item != 'RVN')
        .toList();
    SelectionItems(context, names: [SelectionOptions.Holdings]).build(
        holdingNames: options.isNotEmpty
            ? ['Ravencoin'] + options
            : ['Ravencoin', 'Amazon']);
  }

  void _produceFeeModal() {
    SelectionItems(context, names: [
      SelectionOptions.Fast,
      SelectionOptions.Standard,
      SelectionOptions.Slow
    ]).build();
  }
}
