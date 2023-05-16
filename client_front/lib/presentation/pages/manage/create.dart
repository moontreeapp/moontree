import 'dart:io' show Platform;
import 'dart:async';
import 'package:client_front/application/manage/create/cubit.dart';
import 'package:client_front/domain/utils/alphacon.dart';
import 'package:client_front/domain/utils/transformers.dart';
import 'package:client_front/presentation/widgets/front_curve.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:intersperse/intersperse.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';
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

class SimpleCreate extends StatefulWidget {
  const SimpleCreate({Key? key}) : super(key: key);

  @override
  _SimpleCreateState createState() => _SimpleCreateState();
}

class _SimpleCreateState extends State<SimpleCreate> {
  //Map<String, dynamic> data = <String, dynamic>{};
  final TextEditingController parentNameController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController decimalsController = TextEditingController();
  final FocusNode parentNameFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode memoFocus = FocusNode();
  final FocusNode quantityFocus = FocusNode();
  final FocusNode decimalsFocus = FocusNode();
  final FocusNode previewFocus = FocusNode();
  final FocusNode reissuableFocus = FocusNode();
  final ScrollController scrollController = ScrollController();
  bool clicked = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    parentNameController.dispose();
    nameController.dispose();
    memoController.dispose();
    quantityController.dispose();
    decimalsController.dispose();
    parentNameFocus.dispose();
    nameFocus.dispose();
    memoFocus.dispose();
    quantityFocus.dispose();
    decimalsFocus.dispose();
    previewFocus.dispose();
    super.dispose();
  }

  void _announceNoCoin(SimpleCreateFormState state) => !_allValidation(state)
      ? streams.app.behavior.snack.add(Snack(
          message: 'please fill out form',
          positive: false,
        ))
      : streams.app.behavior.snack.add(Snack(
          message: 'No coin in wallet - unable to pay fees',
          positive: false,
        ));

  @override
  Widget build(BuildContext context) {
    final SimpleCreateFormCubit cubit =
        BlocProvider.of<SimpleCreateFormCubit>(context);
    //data = populateData(context, data); // why
    return GestureDetector(
        onTap: () {
          // getting error on back button.
          try {
            FocusScope.of(context).unfocus();
          } catch (e) {
            return;
          }
        },
        child: BlocBuilder<SimpleCreateFormCubit, SimpleCreateFormState>(
            bloc: cubit..enter(),
            builder: (BuildContext context, SimpleCreateFormState state) {
              parentNameController.text = state.parentName;
              if (state.name.length > 0) {
                nameController.value = TextEditingValue(
                    text: state.name,
                    selection:
                        nameController.selection.baseOffset > state.name.length
                            ? TextSelection.collapsed(offset: state.name.length)
                            : nameController.selection);
              }
              if (state.memo.length > 0) {
                memoController.value = TextEditingValue(
                    text: state.memo,
                    selection:
                        memoController.selection.baseOffset > state.memo.length
                            ? TextSelection.collapsed(offset: state.memo.length)
                            : memoController.selection);
              }
              if (state.quantity.toString().length > 0 && state.quantity != 0) {
                quantityController.value = TextEditingValue(
                    text: state.quantity.toString(),
                    selection: quantityController.selection.baseOffset >
                            state.quantity.toString().length
                        ? TextSelection.collapsed(
                            offset: state.quantity.toString().length)
                        : quantityController.selection);
              }
              if (state.decimals.toString().length > 0) {
                decimalsController.value = TextEditingValue(
                    text: state.decimals.toString(),
                    selection: decimalsController.selection.baseOffset >
                            state.decimals.toString().length
                        ? TextSelection.collapsed(
                            offset: state.decimals.toString().length)
                        : decimalsController.selection);
              }
              return ScrollablePageStructure(
                headerSpace: Platform.isIOS ? 16 : 8,
                children: <Widget>[
                  TextFieldFormatted(
                    focusNode: parentNameFocus,
                    controller: parentNameController,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    labelText: 'Parent Asset',
                    hintText: "what asset is this asset a part of?",
                    prefixIcon: parentNameController.text != ''
                        ? PrefixAssetCoinIcon(symbol: parentNameController.text)
                        : null,
                    // //decoration: styles.decorations.textField(context,
                    // //    focusNode: sendAssetFocusNode,
                    // //    labelText: 'Asset',
                    // //    hintText: pros.settings.chain.title,
                    // //    prefixIcon: components.icons.assetAvatar(
                    // //        holdingView!.symbol,
                    // //        net: pros.settings.net)),
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
                      FocusScope.of(context).requestFocus(nameFocus);
                    },
                  ),
                  TextFieldFormatted(
                    focusNode: nameFocus,
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    selectionControls: CustomMaterialTextSelectionControls(
                        context: components.routes.routeContext,
                        offset: Offset.zero),
                    autocorrect: false,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter(
                        RegExp(r'[a-zA-Z0-9._#]'),
                        allow: true,
                      ),
                      UpperCaseTextFormatter(),
                    ],
                    labelText: 'Name',
                    hintText: "what's the name of this asset?",
                    errorText: nameController.text == ''
                        ? null
                        : _validateName()
                            ? null
                            : '3-30 characters, special chars allowed: _ . #',
                    onChanged: (String value) => cubit.set(name: value),
                    onEditingComplete: () {
                      cubit.set(name: nameController.text);
                      FocusScope.of(context).requestFocus(quantityFocus);
                    },
                  ),
                  TextFieldFormatted(
                    focusNode: quantityFocus,
                    controller: quantityController,
                    textInputAction: TextInputAction.next,
                    keyboardType: const TextInputType.numberWithOptions(
                      signed: false,
                      decimal: false,
                    ),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter(
                        RegExp(r'^[1-9]\d*$'),
                        allow: true,
                      )
                    ],
                    labelText: 'Quantity',
                    hintText: 'how many coins should be minted?',
                    errorText: quantityController.text == ''
                        ? null
                        : _validateQuantity()
                            ? null
                            : 'too large',
                    onChanged: (String value) {
                      if (_validateQuantity()) {
                        try {
                          cubit.set(quantity: int.parse(value));
                        } catch (e) {
                          cubit.set(quantity: 0);
                        }
                      }
                    },
                    onEditingComplete: () {
                      if (_validateQuantity()) {
                        try {
                          cubit.set(
                              quantity: int.parse(quantityController.text));
                        } catch (e) {
                          cubit.set(quantity: 0);
                        }
                      }

                      //// causes error on ios. as the keyboard becomes dismissed the bottom modal sheet is attempting to appear, they collide.
                      //FocusScope.of(context).requestFocus(sendFeeFocusNode);
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  TextFieldFormatted(
                    onTap: () => _produceDecimalsModal(cubit),
                    focusNode: decimalsFocus,
                    controller: decimalsController,
                    readOnly: true,
                    textInputAction: TextInputAction.next,
                    labelText: 'Decimals',
                    hintText:
                        'to how many decimal places is each coin divisible?',
                    suffixIcon: IconButton(
                        icon: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SvgPicture.asset(
                                'assets/icons/custom/black/chevron-down.svg')
                            //Icon(Icons.expand_more_rounded,
                            //    color: AppColors.black60)
                            ),
                        onPressed: () => _produceDecimalsModal(cubit)),
                    onChanged: (String newValue) {
                      cubit.set(decimals: int.parse(decimalsController.text));
                      FocusScope.of(context).requestFocus(memoFocus);
                    },
                  ),
                  TextFieldFormatted(
                      focusNode: memoFocus,
                      controller: memoController,
                      textInputAction: TextInputAction.next,
                      labelText: 'Memo',
                      hintText: 'IPFS',
                      helperText: memoFocus.hasFocus
                          ? 'will be saved on the blockchain'
                          : null,
                      helperStyle: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .copyWith(height: .7, color: AppColors.primary),
                      errorText: _validateMemo() ? null : 'too long',
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
                        cubit.set(memo: memoController.text);
                        FocusScope.of(context).requestFocus(reissuableFocus);
                      }),
                  Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: SwtichChoice(
                        label: 'Reissuable',
                        description:
                            "A reissuable asset's quantity and decimal places can increase in the future.",
                        hideDescription: true,
                        initial: cubit.state.reissuable,
                        onChanged: (bool value) async =>
                            cubit.set(reissuable: value),
                      )),
                ],
                firstLowerChildren: <Widget>[
                  BottomButton(
                    enabled: _allValidation(state) && !clicked,
                    focusNode: previewFocus,
                    label: !clicked ? 'Preview' : 'Generating Transaction...',
                    disabledOnPressed: () => _announceNoCoin(state),
                    onPressed: () {
                      cubit.set(
                        parentName: parentNameController.text,
                        name: nameController.text,
                        memo: memoController.text,
                        quantity: int.parse(quantityController.text),
                        decimals: int.parse(decimalsController.text),
                        //reissuable: reissuableController.text,
                      );
                      setState(() {
                        clicked = true;
                      });
                      _startSend(cubit, state);
                    },
                  ),
                ],
              );
            }));
  }

  bool _validateMemo([String? memo]) =>
      (memo ?? memoController.text).isIpfs ||
      (memo ?? memoController.text).isMemo;

  bool _validateName([String? name]) =>
      (name ?? nameController.text).isAssetPath;

  bool _validateQuantity([String? quantity]) {
    quantity = (quantity ?? quantityController.text);
    if (quantity.contains('.') ||
        quantity.contains(',') ||
        quantity.contains('-') ||
        quantity.contains(' ')) {
      return false;
    }
    int intQ;
    try {
      intQ = int.parse(quantity);
      return intQ <= 21000000;
    } catch (e) {
      return false;
    }
  }

  bool _allValidation(SimpleCreateFormState state) =>
      _validateName() && _validateQuantity() && _validateMemo();

  void _startSend(SimpleCreateFormCubit cubit, SimpleCreateFormState state) {
    final bool vAddress = nameController.text != '';
    final bool vMemo = _validateMemo();
    if (vAddress && vMemo) {
      FocusScope.of(context).unfocus();
      //final SendRequest sendRequest = SendRequest(
      //  sendAll: false,
      //  wallet: Current.wallet,
      //  nameController: state.name,
      //  holding: holdingBalance.amount,
      //  visibleAmount: _asDoubleString(state.amount),
      //  sendAmountAsSats: state.sats,
      //  feeRate: state.fee,
      //  security: state.security,
      //  assetMemo: state.security != pros.securities.currentCoin &&
      //          state.memo != '' &&
      //          state.memo.isIpfs
      //      ? state.memo
      //      : null,
      //  //TODO: Currently memos are only for non-asset transactions
      //  memo: state.security == pros.securities.currentCoin &&
      //          state.memo != '' &&
      //          _validateMemo(state.memo)
      //      ? state.memo
      //      : null,
      //  note: state.note != '' ? state.note : null,
      //);
      //_confirmSend(sendRequest, cubit);
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate proclaim? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....

  void _confirmSend(
      SendRequest sendRequest, SimpleCreateFormCubit cubit) async {
    //streams.spend.make.add(sendRequest); // using cubit instead, poorly
    /*
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
        checkout: SimpleCreateCheckoutForm(
      symbol: sendRequest.security!.symbol,
      displaySymbol: sendRequest.security!.name,
      subSymbol: '',
      paymentSymbol: pros.securities.currentCoin.symbol,
      items: <List<String>>[
        <String>['To', sendRequest.nameController],
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
    */
  }

  void _produceAssetModal(SimpleCreateFormCubit cubit) =>
      components.cubits.bottomModalSheet.show(children: <Widget>[
        for (String name in Current.holdingNames
            .where((String item) => item.isAdmin)
            .map((e) => Symbol(e).toMainSymbol!))
          ListTile(
              onTap: () {
                context.read<BottomModalSheetCubit>().hide();
                final sec = pros.securities.ofCurrent(name) ??
                    Security(
                        symbol: '',
                        chain: pros.settings.chain,
                        net: pros.settings.net);
                cubit.set(parentName: sec.symbol);
              },
              leading: components.icons.assetAvatar(name,
                  height: 24, width: 24, net: pros.settings.net),
              title: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(symbolName(name),
                      style: Theme.of(context).textTheme.bodyLarge)))
      ]);

  void _produceDecimalsModal(SimpleCreateFormCubit cubit) {
    final imageDetails = ImageDetails(
        foreground: AppColors.rgb(AppColors.primary),
        background: AppColors.rgb(AppColors.lightPrimaries[1]));
    components.cubits.bottomModalSheet.show(children: <Widget>[
      for (final decimal in [
        Tuple2<String, int>('${cubit.state.quantity}', 0),
        Tuple2<String, int>('${cubit.state.quantity}.0', 1),
        Tuple2<String, int>('${cubit.state.quantity}.00', 2),
        Tuple2<String, int>('${cubit.state.quantity}.000', 3),
        Tuple2<String, int>('${cubit.state.quantity}.0000', 4),
        Tuple2<String, int>('${cubit.state.quantity}.00000', 5),
        Tuple2<String, int>('${cubit.state.quantity}.000000', 6),
        Tuple2<String, int>('${cubit.state.quantity}.0000000', 7),
        Tuple2<String, int>('${cubit.state.quantity}.00000000', 8),
      ])
        ListTile(
          onTap: () {
            context.read<BottomModalSheetCubit>().hide();
            cubit.set(decimals: decimal.item2);
          },
          leading: components.icons.assetFromCacheOrGenerate(
              asset: decimal.item2.toString() + 'ABC',
              height: 24,
              width: 24,
              imageDetails: imageDetails,
              assetType: SymbolType.main),
          title:
              Text(decimal.item1, style: Theme.of(context).textTheme.bodyLarge),
        )
    ]);
  }
}
