/*
import 'dart:io' show Platform;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intersperse/intersperse.dart';
import 'package:ravencoin_front/concepts/concepts.dart' as concepts;
import 'package:ravencoin_front/cubits/send/cubit.dart';
import 'package:ravencoin_front/cubits/parents.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/utils/qrcode.dart';
import 'package:ravencoin_front/widgets/other/selection_control.dart';

import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:wallet_utils/wallet_utils.dart' as ravencoin;

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
  final sendAsset = TextEditingController();
  final sendAddress = TextEditingController();
  final sendAmount = TextEditingController();
  final sendFee = TextEditingController();
  final sendMemo = TextEditingController();
  final sendNote = TextEditingController();
  FocusNode sendAssetFocusNode = FocusNode();
  FocusNode sendAddressFocusNode = FocusNode();
  FocusNode sendAmountFocusNode = FocusNode();
  FocusNode sendFeeFocusNode = FocusNode();
  FocusNode sendMemoFocusNode = FocusNode();
  FocusNode sendNoteFocusNode = FocusNode();
  FocusNode previewFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  String addressName = '';
  double? minHeight;
  String visibleAmount = '0';
  bool clicked = false;
  bool validatedAddress = true;

  @override
  void initState() {
    super.initState();
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
    if (data.containsKey('qrCode')) {
      handlePopulateFromQR(data['qrCode']);
      data.remove('qrCode');
    }
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: BlocProvider<SimpleSendFormCubit>(
          create: (context) => SimpleSendFormCubit(),
          child: BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
              bloc: BlocProvider.of<SimpleSendFormCubit>(context)..enter(),
              builder: (context, state) {
                final cubit = BlocProvider.of<SimpleSendFormCubit>(context);
                return BackdropLayers(
                  backAlignment: Alignment.bottomCenter,
                  frontAlignment: Alignment.topCenter,
                  front: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      CoinSpec(
                          pageTitle: 'Send',
                          security: state.security,
                          color: Theme.of(context).backgroundColor),
                      FrontCurve(
                          fuzzyTop: false,
                          height: 8,
                          frontLayerBoxShadow: [
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
                  back: Container(
                      color: AppColors.white,
                      child: Stack(
                        children: [
                          ListView(
                            physics: ClampingScrollPhysics(),
                            padding: EdgeInsets.only(
                                left: 16, right: 16, top: 16, bottom: 0),
                            children: <Widget>[
                              SizedBox(height: 8),
                              if (Platform.isIOS) SizedBox(height: 8),
                              Container(height: 201),
                              SizedBox(height: 8),
                              ...<Widget>[
                                TextFieldFormatted(
                                  focusNode: sendAssetFocusNode,
                                  controller: sendAsset,
                                  readOnly: true,
                                  textInputAction: TextInputAction.next,
                                  decoration: components.styles.decorations
                                      .textField(context,
                                          focusNode: sendAssetFocusNode,
                                          labelText: 'Asset',
                                          hintText:
                                              chainName(pros.settings.chain),
                                          suffixIcon: IconButton(
                                            icon: Padding(
                                                padding:
                                                    EdgeInsets.only(right: 14),
                                                child: Icon(
                                                    Icons.expand_more_rounded,
                                                    color: Color(0xDE000000))),
                                            onPressed: _produceAssetModal,
                                          )),
                                  onTap: _produceAssetModal,
                                  onChanged: (value) {
                                    cubit.set(
                                        security: pros.securities
                                                .ofCurrent(symbolName(value)) ??
                                            pros.securities.currentCoin);
                                  },
                                  onEditingComplete: () async {
                                    cubit.set(
                                        security: pros.securities.ofCurrent(
                                                symbolName(sendAsset.text)) ??
                                            pros.securities.currentCoin);
                                    FocusScope.of(context)
                                        .requestFocus(sendAddressFocusNode);
                                  },
                                ),
                                TextFieldFormatted(
                                  focusNode: sendAddressFocusNode,
                                  controller: sendAddress,
                                  textInputAction: TextInputAction.next,
                                  selectionControls:
                                      CustomMaterialTextSelectionControls(
                                          context: components
                                              .navigator.scaffoldContext,
                                          offset: Offset(0, 0)),
                                  autocorrect: false,
                                  inputFormatters: [
                                    FilteringTextInputFormatter(
                                        RegExp(r'[a-zA-Z0-9]'),
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
                                          padding: EdgeInsets.only(right: 14),
                                          child: Icon(Icons.paste_rounded,
                                              color: Color(0xDE000000))),
                                      onPressed: () async {
                                        var clip = (await Clipboard.getData(
                                                    'text/plain'))
                                                ?.text ??
                                            '';
                                        setState(() => sendAddress.text = clip);
                                      }),
                                  onChanged: (value) =>
                                      cubit.set(address: value),
                                  onEditingComplete: () {
                                    cubit.set(address: sendAddress.text);
                                    FocusScope.of(context)
                                        .requestFocus(sendAmountFocusNode);
                                  },
                                ),
                                TextFieldFormatted(
                                  focusNode: sendAmountFocusNode,
                                  controller: sendAmount,
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal: true, signed: false),
                                  inputFormatters: <TextInputFormatter>[
                                    //DecimalTextInputFormatter(decimalRange: divisibility)
                                    FilteringTextInputFormatter(
                                        RegExp(r'[.0-9]'),
                                        allow: true)
                                  ],
                                  labelText: 'Amount',
                                  hintText: 'Quantity',
                                  errorText: sendAmount.text == ''
                                      ? null
                                      : sendAmount.text == '0.0'
                                          ? 'must be greater than 0'
                                          : asDouble(sendAmount.text) >
                                                  (state.security.balance
                                                          ?.value ??
                                                      0)
                                              ? 'too large'
                                              : (String x) {
                                                  if (x.isNumeric) {
                                                    var y = x.toNum();
                                                    if (y != null &&
                                                        y.isRVNAmount) {
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
                                    if (asDouble(value) >
                                        (state.security.balance?.value ?? 0)) {
                                      value =
                                          (state.security.balance?.value ?? 0)
                                              .toString();
                                      sendAmount.text =
                                          (state.security.balance?.value ?? 0)
                                              .toString();
                                    }
                                    visibleAmount =
                                        verifyVisibleAmount(value, state);
                                    cubit.set(amount: asDouble(visibleAmount));
                                  },
                                  onEditingComplete: () {
                                    sendAmount.text = enforceDivisibility(
                                        sendAmount.text,
                                        divisibility:
                                            state.security.divisibility);
                                    visibleAmount = verifyVisibleAmount(
                                        sendAmount.text, state);
                                    cubit.set(amount: asDouble(visibleAmount));
                                    //// causes error on ios. as the keyboard becomes dismissed the bottom modal sheet is attempting to appear, they collide.
                                    //FocusScope.of(context).requestFocus(sendFeeFocusNode);
                                    FocusScope.of(context).unfocus();
                                  },
                                ),
                                TextFieldFormatted(
                                  onTap: _produceFeeModal,
                                  focusNode: sendFeeFocusNode,
                                  controller: sendFee,
                                  readOnly: true,
                                  textInputAction: TextInputAction.next,
                                  labelText: 'Transaction Speed',
                                  hintText: 'Standard',
                                  suffixIcon: IconButton(
                                      icon: Padding(
                                          padding: EdgeInsets.only(right: 14),
                                          child: Icon(Icons.expand_more_rounded,
                                              color: Color(0xDE000000))),
                                      onPressed: _produceFeeModal),
                                  onChanged: (String newValue) {
                                    //sendFee.text = newValue; //necessary?
                                    cubit.set(
                                        fee: {
                                              'Cheap': ravencoin.FeeRates.cheap,
                                              'Standard':
                                                  ravencoin.FeeRates.standard,
                                              'Fast': ravencoin.FeeRates.fast,
                                            }[newValue] ??
                                            ravencoin.FeeRates.standard);
                                    FocusScope.of(context)
                                        .requestFocus(sendFeeFocusNode);
                                    setState(() {});
                                  },
                                ),
                                TextFieldFormatted(
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
                                        .caption!
                                        .copyWith(
                                            height: .7,
                                            color: AppColors.primary),
                                    errorText: verifyMemo() ? null : 'too long',
                                    suffixIcon: IconButton(
                                        icon: Icon(Icons.paste_rounded,
                                            color: AppColors.black60),
                                        onPressed: () async {
                                          sendMemo.text =
                                              (await Clipboard.getData(
                                                          'text/plain'))
                                                      ?.text ??
                                                  '';
                                        }),
                                    onChanged: (value) =>
                                        cubit.set(memo: value),
                                    onEditingComplete: () {
                                      cubit.set(memo: sendMemo.text);
                                      FocusScope.of(context)
                                          .requestFocus(sendNoteFocusNode);
                                    }),
                                TextFieldFormatted(
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
                                        .caption!
                                        .copyWith(
                                            height: .7,
                                            color: AppColors.primary),
                                    suffixIcon: IconButton(
                                      icon: Icon(Icons.paste_rounded,
                                          color: AppColors.black60),
                                      onPressed: () async {
                                        sendNote.text =
                                            (await Clipboard.getData(
                                                        'text/plain'))
                                                    ?.text ??
                                                '';
                                      },
                                    ),
                                    onChanged: (value) =>
                                        cubit.set(note: value),
                                    onEditingComplete: () {
                                      cubit.set(note: sendNote.text);
                                      FocusScope.of(context)
                                          .requestFocus(previewFocusNode);
                                    }),
                              ].intersperse(SizedBox(height: 16)),
                              SizedBox(height: 64),
                            ],
                          ),
                          KeyboardHidesWidgetWithDelay(
                              child: components.buttons.layeredButtons(
                            context,
                            buttons: [
                              sendTransactionButton(disabled: !allValidation())
                            ],
                            widthSpacer: SizedBox(width: 16),
                          ))
                        ],
                      )),
                );
              })),
    );
  }

  double asDouble(String visibleAmount) =>
      ['', '.'].contains(visibleAmount) ? 0 : double.parse(visibleAmount);

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

  // ignore: unused_element
  bool _validateAddressColor([String? address]) {
    var old = validatedAddress;
    validatedAddress = _validateAddress(address ?? sendAddress.text);
    if (old != validatedAddress) setState(() => {});
    return validatedAddress;
  }

  String verifyVisibleAmount(String value, SimpleSendFormState state) {
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
      if (amount != '' &&
          double.parse(amount) <= (state.security.balance?.value ?? 0)) {
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

  bool holdingValidation(SimpleSendFormState state) {
    sendAmount.text = cleanDecAmount(sendAmount.text, zeroToBlank: true);
    if (sendAmount.text == '') {
      return false;
    } else {
      return state.security.balance.value >= double.parse(sendAmount.text);
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
      if (state.security.balance.value >= double.parse(sendAmount.text)) {
        var sendRequest = SendRequest(
          sendAll: state.security.balance.value == visibleAmount.toDouble(),
          wallet: Current.wallet,
          sendAddress: sendAddress.text,
          holding: state.security.balance.value,
          visibleAmount: visibleAmount,
          sendAmountAsSats: sendAmountAsSats,
          feeRate: feeRate,
          security: sendAsset.text == chainName(pros.settings.chain)
              ? null
              : pros.securities.primaryIndex.getOne(
                  sendAsset.text,
                  SecurityType.asset,
                  pros.settings.chain,
                  pros.settings.net,
                ),
          assetMemo: sendAsset.text != chainName(pros.settings.chain) &&
                  sendMemo.text != '' &&
                  sendMemo.text.isIpfs
              ? sendMemo.text
              : null,
          //TODO: Currently memos are only for non-asset transactions
          memo: sendAsset.text == chainName(pros.settings.chain) &&
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
          symbol: ((streams.spend.form.value?.symbol ==
                      chainName(pros.settings.chain)
                  ? pros.securities.currentCoin.symbol
                  : streams.spend.form.value?.symbol) ??
              pros.securities.currentCoin.symbol),
          displaySymbol: ((streams.spend.form.value?.symbol ==
                      chainName(pros.settings.chain)
                  ? chainName(pros.settings.chain)
                  : streams.spend.form.value?.symbol) ??
              chainName(pros.settings.chain)),
          subSymbol: '',
          paymentSymbol: pros.securities.currentCoin.symbol,
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
        .where((item) => item != pros.securities.currentCoin.symbol)
        .toList();
    final head = Current.holdingNames
        .where((item) => item == pros.securities.currentCoin.symbol)
        .toList();
    SimpleSelectionItems(context, items: [
      for (var name in head + tail)
        ListTile(
            visualDensity: VisualDensity.compact,
            onTap: () {
              Navigator.pop(context);
              sendAsset.text = name;
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
            title: Text(symbolName(name),
                style: Theme.of(context).textTheme.bodyText1))
    ]).build();
    //SelectionItems(context, modalSet: SelectionSet.Holdings)
    //    .build(holdingNames: head + tail);
  }

  void _produceFeeModal() {
    SimpleSelectionItems(context, items: [
      for (var feeOption in [concepts.fees.fast, concepts.fees.standard])
        ListTile(
          visualDensity: VisualDensity.compact,
          onTap: () {
            Navigator.pop(context);
            sendFee.text = feeOption.nameTitlecase;
          },
          leading: feeOption.icon,
          title: Text(feeOption.nameTitlecase,
              style: Theme.of(context).textTheme.bodyText1),
          trailing: null,
        )
    ]).build();
    //SelectionItems(context, modalSet: SelectionSet.Fee).build();
  }
}

class ToName extends StatelessWidget {
  final Cubit cubit;
  final CubitState state;
  final FocusNode focus;
  final FocusNode nextFocus;
  ToName({
    Key? key,
    required this.cubit,
    required this.state,
    required this.focus,
    required this.nextFocus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) =>
      Visibility(visible: addressName != '', child: Text('To: $addressName'));
}


*/