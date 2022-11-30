import 'dart:io' show Platform;
import 'dart:async';
import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ravencoin_back/ravencoin_back.dart';
import 'package:ravencoin_back/services/transaction/maker.dart';
import 'package:ravencoin_back/streams/app.dart';
import 'package:ravencoin_front/cubits/send/cubit.dart';
import 'package:ravencoin_front/components/components.dart';
import 'package:ravencoin_front/concepts/concepts.dart' as concepts;
import 'package:ravencoin_front/widgets/other/selection_control.dart';
import 'package:ravencoin_front/widgets/widgets.dart';
import 'package:ravencoin_front/services/lookup.dart';
import 'package:ravencoin_front/theme/theme.dart';
import 'package:ravencoin_front/pages/misc/checkout.dart';
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
  String visibleAmount = '0';
  bool clicked = false;
  bool validatedAddress = true;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<SimpleSendFormCubit>(context)..reset();
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

  void _announceNoCoin() => streams.app.snack.add(Snack(
        message: 'No coin in wallet - unable to pay fees',
        positive: false,
      ));

  void populateFromData(SimpleSendFormCubit cubit) {
    if (data.isNotEmpty) {
      if ([null, pros.settings.chain.name].contains(data['chain'])) {
        if ([null, pros.settings.net.name].contains(data['net'])) {
          cubit.set(
            security: data['security'] ?? cubit.state.security,
            address: data['address'] ?? cubit.state.address,
            addressName: data['addressName'] ?? cubit.state.addressName,
            amount: data['amount'] ?? cubit.state.amount,
            fee: data['fee'] ?? cubit.state.fee,
            memo: data['memo'] ?? cubit.state.memo,
            note: data['note'] ?? cubit.state.note,
          );
        } else {
          streams.app.snack.add(Snack(
            message: 'Not connected to ${data['chain']} ${data['net']}',
            positive: false,
          ));
        }
      } else {
        streams.app.snack.add(Snack(
          message: 'Not connected to ${data['chain']}',
          positive: false,
        ));
      }
      data = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<SimpleSendFormCubit>(context);
    data = populateData(context, data);
    populateFromData(cubit);
    return GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: BlocBuilder<SimpleSendFormCubit, SimpleSendFormState>(
            bloc: cubit..enter(),
            builder: (context, state) {
              sendAsset.text = state.security.name;
              if (state.amount > 0) {
                final text = enforceDivisibility(
                  _asDoubleString(state.amount),
                  divisibility: state.security.divisibility,
                );
                sendAmount.value = TextEditingValue(
                    text: text,
                    selection: sendAmount.selection.baseOffset > text.length
                        ? TextSelection.collapsed(offset: text.length)
                        : sendAmount.selection);
              }
              sendAddress.text = state.address;
              sendFee.text = state.fee.name!;
              sendMemo.text = state.memo;
              sendNote.text = state.note;
              return BackdropLayers(
                backAlignment: Alignment.bottomCenter,
                frontAlignment: Alignment.topCenter,
                front: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    CoinSpec(
                        cubit: cubit,
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
                                          onPressed: () =>
                                              _produceAssetModal(cubit),
                                        )),
                                onTap: () => _produceAssetModal(cubit),
                                onChanged: (value) {},
                                onEditingComplete: () async {
                                  FocusScope.of(context)
                                      .requestFocus(sendAddressFocusNode);
                                },
                              ),
                              if (addressName != '') Text('To: $addressName'),
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
                                            color: AppColors.black60)),
                                    onPressed: () async => cubit.set(
                                        address: (await Clipboard.getData(
                                                    'text/plain'))
                                                ?.text ??
                                            '')),
                                onChanged: (value) => cubit.set(address: value),
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
                                  FilteringTextInputFormatter(RegExp(r'[.0-9]'),
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
                                  if (_asDouble(x) >
                                      (state.security.balance?.amount ?? 0)) {
                                    return 'too large';
                                  }
                                  if (x.isNumeric) {
                                    var y = x.toNum();
                                    if (y != null && y.isRVNAmount) {
                                      return null;
                                    }
                                  }
                                  return 'Unrecognized Amount';
                                }(sendAmount.text),
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
                                    },
                                  ),
                                  */
                                onChanged: (value) {
                                  value = enforceDivisibility(value,
                                      divisibility:
                                          state.security.divisibility);
                                  try {
                                    cubit.set(amount: double.parse(value));
                                  } catch (e) {
                                    cubit.set(amount: 0);
                                  }
                                },
                                onEditingComplete: () {
                                  var value = sendAmount.text;
                                  value = enforceDivisibility(value,
                                      divisibility:
                                          state.security.divisibility);
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
                                onTap: () => _produceFeeModal(cubit),
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
                                          height: .7, color: AppColors.primary),
                                  errorText: _verifyMemo() ? null : 'too long',
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.paste_rounded,
                                          color: AppColors.black60),
                                      onPressed: () async => cubit.set(
                                          memo: (await Clipboard.getData(
                                                      'text/plain'))
                                                  ?.text ??
                                              '')),
                                  onChanged: (value) => cubit.set(memo: value),
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
                                          height: .7, color: AppColors.primary),
                                  suffixIcon: IconButton(
                                      icon: Icon(Icons.paste_rounded,
                                          color: AppColors.black60),
                                      onPressed: () async => cubit.set(
                                          note: (await Clipboard.getData(
                                                      'text/plain'))
                                                  ?.text ??
                                              '')),
                                  onChanged: (value) => cubit.set(note: value),
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
                            components.buttons.actionButton(
                              context,
                              focusNode: previewFocusNode,
                              enabled: _allValidation(state) && !clicked,
                              label: !clicked
                                  ? 'Preview'
                                  : 'Generating Transaction...',
                              onPressed: () {
                                setState(() {
                                  clicked = true;
                                });
                                _startSend(state);
                              },
                              disabledOnPressed: () {
                                if (!_coinValidation()) {
                                  _announceNoCoin();
                                }
                              },
                            )
                          ],
                          widthSpacer: SizedBox(width: 16),
                        ))
                      ],
                    )),
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

  bool _coinValidation() =>
      pros.balances.primaryIndex
          .getOne(Current.walletId, pros.securities.currentCoin) !=
      null;

  bool _fieldValidation() {
    return sendAddress.text != '' && _validateAddress() && _verifyMemo();
  }

  bool _holdingValidation(SimpleSendFormState state) {
    if (_asDouble(sendAmount.text) == 0.0) {
      return false;
    }
    return (state.security.balance?.amount ?? 0) >=
        double.parse(sendAmount.text);
  }

  bool _allValidation(SimpleSendFormState state) {
    return _coinValidation() && _fieldValidation() && _holdingValidation(state);
  }

  void _startSend(SimpleSendFormState state) {
    var vAddress = sendAddress.text != '' && _validateAddress();
    var vMemo = _verifyMemo();
    if (vAddress && vMemo) {
      FocusScope.of(context).unfocus();
      if ((state.security.balance?.amount ?? 0) >=
          double.parse(sendAmount.text)) {
        var sendRequest = SendRequest(
          sendAll: (state.security.balance?.amount ?? 0) == state.amount,
          wallet: Current.wallet,
          sendAddress: state.address,
          holding: (state.security.balance?.amount ?? 0.0),
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
        _confirmSend(sendRequest);
      }
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate proclaim? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....

  void _confirmSend(SendRequest sendRequest) {
    streams.spend.make.add(sendRequest);
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          symbol: sendRequest.security!.symbol,
          displaySymbol: sendRequest.security!.name,
          subSymbol: '',
          paymentSymbol: pros.securities.currentCoin.symbol,
          items: [
            ['To', sendRequest.sendAddress],
            if (addressName != '') ['Known As', addressName],
            [
              'Amount',
              sendRequest.sendAll
                  ? 'calculating amount...'
                  : sendRequest.visibleAmount
            ],
            if (!['', null].contains(sendRequest.memo))
              ['Memo', sendRequest.memo!],
            if (!['', null].contains(sendRequest.note))
              ['Note', sendRequest.note!],
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

  void _produceAssetModal(SimpleSendFormCubit cubit) {
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
              cubit.set(
                  security: pros.securities.ofCurrent(nameSymbol(name)) ??
                      pros.securities.currentCoin);
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
  }

  void _produceFeeModal(SimpleSendFormCubit cubit) {
    SimpleSelectionItems(context, items: [
      for (var feeConcept in [concepts.fees.fast, concepts.fees.standard])
        ListTile(
          visualDensity: VisualDensity.compact,
          onTap: () {
            Navigator.pop(context);
            cubit.set(fee: feeConcept.feeRate);
          },
          leading: feeConcept.icon,
          title: Text(feeConcept.nameTitlecase,
              style: Theme.of(context).textTheme.bodyText1),
          trailing: null,
        )
    ]).build();
  }
}
