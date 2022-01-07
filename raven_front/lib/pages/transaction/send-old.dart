import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:ravencoin_wallet/ravencoin_wallet.dart' as ravencoin;
import 'package:barcode_scan2/barcode_scan2.dart';

import 'package:raven_back/services/transaction/fee.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_back/raven_back.dart';

import 'package:raven_front/components/components.dart';
import 'package:raven_front/indicators/indicators.dart';
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
  final sendAddress = TextEditingController();
  final sendAmount = TextEditingController();
  final sendMemo = TextEditingController();
  final sendNote = TextEditingController();
  String visibleAmount = '0';
  String visibleFiatAmount = '';
  String validatedAddress = 'unknown';
  String validatedAmount = '-1';
  Color addressColor = Colors.grey.shade400;
  Color amountColor = Colors.grey.shade400;
  Color memoColor = Colors.grey.shade400;
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
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    sendAddress.dispose();
    sendAmount.dispose();
    sendMemo.dispose();
    sendNote.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // could hold which asset to send...
    data = populateData(context, data);
    useWallet = data.containsKey('walletId') && data['walletId'] != null;
    var divisibility = 8; /* get asset divisibility...*/
    var possibleHoldings = [
      for (var balance in useWallet
          ? Current.walletHoldings(data['walletId'])
          : Current.holdings)
        if (balance.security.symbol == data['symbol'])
          satToAmount(balance.confirmed)
    ];
    if (possibleHoldings.length > 0) {
      holding = possibleHoldings[0];
    }
    try {
      visibleFiatAmount = components.text.securityAsReadable(
          amountToSat(
            double.parse(visibleAmount),
            divisibility: divisibility,
          ),
          symbol: data['symbol'],
          asUSD: true);
    } catch (e) {
      visibleFiatAmount = '';
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          //appBar: header(),
          body: body(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: sendTransactionButton(),
          //bottomNavigationBar: components.buttons.bottomNav(context), // alpha hide
        ));
  }

  PreferredSize header() => PreferredSize(
      preferredSize: Size.fromHeight(MediaQuery.of(context).size.height * 0.28),
      child: AppBar(
          elevation: 2,
          centerTitle: false,
          leading: components.buttons.back(context),
          actions: <Widget>[
            components.status,
            indicators.process,
            indicators.client,
          ],
          title: Text('Send'),
          flexibleSpace: Container(
            alignment: Alignment.center,
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  SizedBox(height: 70.0),
                  Text(visibleAmount,
                      style: Theme.of(context).textTheme.headline3),
                  SizedBox(height: 15.0),
                  Text(visibleFiatAmount,
                      style: Theme.of(context).textTheme.headline5),
                  SizedBox(height: 15.0),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Container(
                        height: 45,
                        width: 45,
                        child: components.icons.assetAvatar(data['symbol'])),
                    SizedBox(width: 15.0),
                    Text(data['symbol'],
                        style: Theme.of(context).textTheme.headline5),
                  ]),
                ])),
          )));

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
      rvnCondition(address ?? sendAddress.text, net: Current.account.net);

  bool _validateAddressColor([String? address]) {
    var old = validatedAddress;
    validatedAddress = validateAddressType(address ?? sendAddress.text);
    if (validatedAddress != '') {
      if ((validatedAddress == 'RVN' && Current.account.net == Net.Main) ||
          (validatedAddress == 'RVNt' && Current.account.net == Net.Test)) {
        addressColor = Theme.of(context).good!;
        //} else if (validatedAddress == 'UNS') {
        //  addressColor = Theme.of(context).primaryColor;
        //} else if (validatedAddress == 'ASSET') {
        //  addressColor = Theme.of(context).primaryColor;
      }
      if (old != validatedAddress) setState(() => {});
      return true;
    }
    addressColor = Theme.of(context).bad!;
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
      amountColor = Theme.of(context).bad!;
    } else {
      // todo: estimate fee
      if (double.parse(visibleAmount) <= holding) {
        amountColor = Theme.of(context).good!;
      } else {
        amountColor = Theme.of(context).bad!;
      }
    }
    setState(() => {});
  }

  bool verifyMemo([String? memo]) => (memo ?? sendMemo.text).length <= 80;
  ListView body() {
    //var _controller = TextEditingController();
    return ListView(
        shrinkWrap: true,
        padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 20.0),
        children: <Widget>[
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
              Widget>[
            Text(useWallet ? 'Use Wallet: ' + data['walletId'] : '',
                style: Theme.of(context).textTheme.caption),
            //DropdownButton<String>(
            //    isExpanded: true,
            //    value: data['symbol'],
            //    items: (useWallet
            //            ? Current.walletHoldingNames(data['walletId'])
            //            : Current.holdingNames)
            //        .map((String value) => DropdownMenuItem<String>(
            //            value: value, child: Text(value)))
            //        .toList(),
            //    onChanged: (String? newValue) {
            //      FocusScope.of(context)
            //          .requestFocus(sendAddressFocusNode);
            //      setState(() => data['symbol'] = newValue!);
            //    }),
            Visibility(
                visible: addressName != '', child: Text('To: $addressName')),
            TextField(
              focusNode: sendAddressFocusNode,
              controller: sendAddress,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: addressColor)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: addressColor)),
                  border: UnderlineInputBorder(
                      borderSide: BorderSide(color: addressColor)),
                  //errorText: _validateAddressColor(sendAddress.text),
                  labelText: 'To',
                  hintText: 'Address'),
              onChanged: (value) {
                _validateAddressColor(value);
              },
              onEditingComplete: () async {
                /// should tell front end what it was so we can notify user we're substituting the asset name or uns domain for the actual address
                //var verifiedAddress =
                //    await verifyValidAddress(sendAddress.text);
                //sendAddress.text = verifiedAddress;
                FocusScope.of(context).requestFocus(sendAmountFocusNode);
                //setState(() {});
              },
            ),
            //Visibility(
            //    visible: !_validateAddress(sendAddress.text),
            //    child: Text(
            //      'Unrecognized Address',
            //      style: TextStyle(color: Theme.of(context).bad),
            //    )),
            TextButton.icon(
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
                icon: Icon(Icons.qr_code_scanner),
                label: Text('Scan QR code')),
            SizedBox(height: 15.0),
            TextField(
              readOnly: sendAll,
              focusNode: sendAmountFocusNode,
              controller: sendAmount,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: amountColor)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: amountColor)),
                  labelText: 'Amount',
                  hintText: 'Quantity'),
              onChanged: (value) {
                verifyVisibleAmount(value);
              },
              onEditingComplete: () {
                sendAmount.text = cleanDecAmount(sendAmount.text);
                verifyVisibleAmount(sendAmount.text);
                FocusScope.of(context).requestFocus(sendFeeFocusNode);
              },
              //validator: (String? value) {  // validate as double/int
              //  //if (value == null || value.isEmpty) {
              //  //  return 'Please enter a valid send amount';
              //  //}
              //  //return null;
              //},
            ),

            // todo replace fee estimate with fast, slow or regular
            //Row(
            //    mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //    children: [Text('fee'), Text('0.01397191 RVN')]),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('remaining', style: Theme.of(context).annotate),
              Text('~ ${holding - double.parse(visibleAmount)}',
                  style: Theme.of(context).annotate),
              TextButton.icon(
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
                  icon: Icon(
                      sendAll ? Icons.not_interested : Icons.all_inclusive),
                  label: Text(sendAll ? "don't send all" : 'send all',
                      style: Theme.of(context).textTheme.caption)),
            ]),
            SizedBox(height: 15.0),
            Text('Transaction Fee', style: Theme.of(context).textTheme.caption),
            DropdownButton<String>(
                focusNode: sendFeeFocusNode,
                isExpanded: true,
                value: feeGoal.name,
                items: [
                  DropdownMenuItem(value: 'Cheap', child: Text('Cheap')),
                  DropdownMenuItem(value: 'Standard', child: Text('Standard')),
                  DropdownMenuItem(value: 'Fast', child: Text('Fast'))
                ],
                onChanged: (String? newValue) {
                  feeGoal = {
                        'Cheap': cheap,
                        'Standard': standard,
                        'Fast': fast,
                      }[newValue] ??
                      standard; // <--- replace by custom dialogue
                  FocusScope.of(context).requestFocus(sendNoteFocusNode);
                  setState(() {});
                }),

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
            SizedBox(height: 15.0),
            TextField(
              focusNode: sendNoteFocusNode,
              controller: sendNote,
              decoration: InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Note (optional)',
                  hintText: 'Private note to self'),
              onEditingComplete: () async => startSend(),
            ),
            //Center(child: sendTransactionButton(_formKey))
          ]),
        ]);
  }

  /// todo: fix the please wait, this is kinda sad:
  Future buildTransactionWithMessageAndConfirm(SendRequest sendRequest) async {
    services.busy.createTransactionOn();
    showDialog(
        context: context,
        builder: (BuildContext context) =>
            //Center(child: CircularProgressIndicator()));
            AlertDialog(title: Text('Generating Transaction...')));
    // this is used to get the please wait message to show up
    // it needs enough time to display the message
    await Future.delayed(const Duration(milliseconds: 150));
    var tuple = services.transaction.make.transactionBy(sendRequest);
    services.busy.createTransactionOff();
    Navigator.pop(context);
    confirmMessage(tx: tuple.item1, estimate: tuple.item2);
  }

  Future startSend() async {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    var vAddress = _validateAddress();
    var vMemo = verifyMemo();
    if (_validateAddress() && verifyMemo()) {
      //sendAmount.text = cleanDecAmount(sendAmount.text);
      //sendAddress.text = await verifyValidAddress(sendAddress.text);
      // if valid form: (
      //    valid to address - is a R34char address, or compiles to one using assetname or UNS,
      //    valid memo - no more than 80 chars long,
      //    valid note - code safe for serialization to and from database)
      // NOT BETA
      // if able to aquire inputs... (from single wallet or account...)
      //    valid asset - this wallet or account has this asset,
      //    valid amount - this wallet or account has this much of this asset (fees taken into account),

      /// press send -> get a confirmation page -> press cancel -> return
      /// press send -> get a confirmation page -> press confirm again -> sends
      /// be sure to save the history record along with the note if successful

      /// NOT BETA
      //if (useWallet) {
      //  // send using only this wallet
      //
      //} else {
      // send using any/every wallet in the account
      FocusScope.of(context).unfocus();
      var sendAmountAsSats = amountToSat(
        double.parse(sendAmount.text),
        divisibility: 8, /* get asset divisibility */
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
        if (settings.primaryIndex.getOne(SettingName.Send_Immediate)!.value) {
          //mpkrK1GLPPdqpaC8qxPVDT5bn5fkAE1UUE
          //23150
          // https://rvnt.cryptoscope.io/address/?address=mpkrK1GLPPdqpaC8qxPVDT5bn5fkAE1UUE
          streams.run.send.add(sendRequest);
          //todo: snackbar notification "sending in background"
          Navigator.pop(context); // leave page so they don't hit send again
        } else {
          try {
            await buildTransactionWithMessageAndConfirm(sendRequest);
          } on InsufficientFunds catch (e) {
            Navigator.pop(context);
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: Text('Error: Insufficient Funds'),
                        content: Text(
                            '$e: Unable to acquire inputs for transaction, this may be due to too many wallets holding too small amounts, a problem known as "dust." Try sending from another account.'),
                        actions: [
                          TextButton(
                              child: Text('Ok'),
                              onPressed: () => Navigator.pop(context))
                        ]));
          } catch (e) {
            showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Unable to create transaction: $e'),
                        actions: [
                          TextButton(
                              child: Text('Ok'),
                              onPressed: () => Navigator.pop(context))
                        ]));
          }
        }
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
  ElevatedButton sendTransactionButton() => ElevatedButton.icon(
      icon: Icon(Icons.send),
      label: Text('Send'),
      onPressed: () async => await startSend(),
      style: components.buttonStyles.curvedSides);

  Future confirmMessage({
    required ravencoin.Transaction tx,
    required SendEstimate estimate,
  }) =>
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: Text('Confirm'),
                  content: DataTable(columns: [
                    DataColumn(label: Text('')),
                    DataColumn(label: Text(''))
                  ], rows: [
                    DataRow(cells: [
                      DataCell(Text('To:')),
                      DataCell(addressName == ''
                          ? Text(sendAddress.text.length < 12
                              ? sendAddress.text
                              : '${sendAddress.text.substring(0, 5)}...${sendAddress.text.substring(sendAddress.text.length - 5, sendAddress.text.length)}')
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                addressNameText(),
                                Text(
                                    sendAddress.text.length < 12
                                        ? sendAddress.text
                                        : '${sendAddress.text.substring(0, 5)}...${sendAddress.text.substring(sendAddress.text.length - 5, sendAddress.text.length)}',
                                    style: Theme.of(context).textTheme.caption),
                              ],
                            )),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Total:')),
                      DataCell(Text(
                          '${satToAmount(estimate.total, divisibility: 8 /* get divisibility */)}')),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Send:')),
                      DataCell(Text(data['symbol'])),
                    ]),
                    /* 
                    // Hide these, we may show some of them later, so comment out:
                    DataRow(cells: [
                      DataCell(Text('Send Amount:')),
                      DataCell(Text(
                          '${components.text.satsToAmount(estimate.amount)}')), //sendAmount.text)),
                    ]),
                    DataRow(cells: [
                      DataCell(Text('Fee Amount:')),
                      DataCell(Text(
                          '${components.text.satsToAmount(estimate.fees)}')),
                    ]),
                    ...[
                      if (sendMemo.text != '')
                        DataRow(cells: [
                          DataCell(Text('Public Memo:')),
                          DataCell(Text(sendMemo.text)),
                        ])
                    ],
                    */
                  ]),
                  actions: [
                    TextButton(
                        child: Text('Cancel'),
                        onPressed: () => Navigator.pop(context)),
                    TextButton(
                        child: Text('Confirm'),
                        onPressed: () async => await attemptSend(tx)

                        /// https://pub.dev/packages/modal_progress_hud
                        //showDialog(
                        //    context: context,
                        //    builder: (BuildContext context) => AlertDialog(
                        //            title: Text(''),
                        //            content: Text('Sending...'),
                        //            actions: [
                        //              TextButton(
                        //                  child: Text('Ok'),
                        //                  onPressed: () =>
                        //                      Navigator.pop(context))
                        //            ]))

                        /*sending...*/
                        /*send to success or failure page*/
                        )
                  ]));

  Widget addressNameText() {
    if (addressName == '') return Text(addressName);
    if (addressName.length < 12) {
      return Text(addressName);
    }
    var names = addressName.split(' ');
    if (names.length > 1) {
      if (names.first.length <= 9) {
        return Text('${names.first} ${names.last.substring(0, 1)}.');
      }
      if (names.last.length <= 9) {
        return Text('${names.first.substring(0, 1)}. ${names.last}');
      }
    }
    return Text(
        '${names.first.substring(0, 6)}... ${names.last.substring(0, 1)}.');
  }

  Future attemptSend(ravencoin.Transaction tx) async {
    var client = streams.client.client.value;
    if (client == null) {
      // replace with snackbar or something
      showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
                  title: Text('Error'),
                  content: Text(
                      'Unable to send Transaction: no connection to the server available. Please try again later.'),
                  actions: [
                    TextButton(
                        child: Text('Ok'),
                        onPressed: () => Navigator.pop(context))
                  ]));
    } else {
      // needs testing on testnet
      var txid = await services.client.api.sendTransaction(tx.toHex());
      //var txid = '';
      if (txid != '') {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: Text('Sent'),
                    content: InkWell(
                        child:
                            Text('Success! See Transaction in browser: $txid'),
                        onTap: () => launch(
                            'https://rvnt.cryptoscope.io/tx/?txid=$txid')),
                    actions: [
                      TextButton(
                          child: Text('Ok'),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                            Navigator.pop(context);
                            //Navigator.popUntil(context, ModalRoute.withName('/login')) // might not have come here from homepage...
                          })
                    ]));
      } else {
        showDialog(
            context: context,
            builder: (BuildContext context) => AlertDialog(
                    title: Text('Unable to verify Transaction'),
                    content: Text(
                        'We were unable to verify the transaction succeeded, please try again later.'),
                    actions: [
                      TextButton(
                          child: Text('Ok'),
                          onPressed: () => Navigator.pop(context))
                    ]));
      }
    }
    //Navigator.pop(context);
  }
}