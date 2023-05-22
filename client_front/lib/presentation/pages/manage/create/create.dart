import 'dart:io' show Platform;
import 'package:tuple/tuple.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_utils/src/utilities/validation.dart'
    show coinsPerChain, ravenNames, satsPerCoin;
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/domain/utils/alphacon.dart';
import 'package:client_front/domain/utils/transformers.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/manage/create/cubit.dart';
import 'package:client_front/application/layers/modal/bottom/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/widgets/other/selection_control.dart';
import 'package:client_front/presentation/services/services.dart' show sail;
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
  final TextEditingController assetMemoController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController decimalsController = TextEditingController();
  final FocusNode parentNameFocus = FocusNode();
  final FocusNode nameFocus = FocusNode();
  final FocusNode assetMemoFocus = FocusNode();
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
    assetMemoController.dispose();
    quantityController.dispose();
    decimalsController.dispose();
    parentNameFocus.dispose();
    nameFocus.dispose();
    assetMemoFocus.dispose();
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

  bool isSub(SymbolType? type) => [
        SymbolType.sub,
        SymbolType.unique,
        SymbolType.channel,
        SymbolType.qualifierSub,
        SymbolType.subAdmin,
      ].contains(type);
  bool isQualifier(SymbolType? type) =>
      [SymbolType.qualifier, SymbolType.qualifierSub].contains(type);
  bool isMain(SymbolType? type) =>
      [SymbolType.main, SymbolType.sub].contains(type);
  bool isRestricted(SymbolType? type) => type == SymbolType.restricted;
  bool isNFT(SymbolType? type) => type == SymbolType.unique;
  bool isChannel(SymbolType? type) => type == SymbolType.channel;

  @override
  Widget build(BuildContext context) {
    final SimpleCreateFormCubit cubit = components.cubits.simpleCreateForm;
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
        //bloc: cubit..enter(),
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
          if (state.assetMemo.length > 0) {
            assetMemoController.value = TextEditingValue(
                text: state.assetMemo,
                selection: assetMemoController.selection.baseOffset >
                        state.assetMemo.length
                    ? TextSelection.collapsed(offset: state.assetMemo.length)
                    : assetMemoController.selection);
          }
          if (isNFT(state.type)) {
            quantityController.text = '1';
            decimalsController.text = '0';
            cubit.update(
              quantity: 1 * satsPerCoin,
              decimals: 0,
              //reissuable: false?
            );
          } else {
            if (state.quantity.toString().length > 0 && state.quantity != 0) {
              final quant = state.quantityCoin.toString().replaceAll('.0', '');
              quantityController.value = TextEditingValue(
                  text: quant,
                  selection:
                      quantityController.selection.baseOffset > quant.length
                          ? TextSelection.collapsed(offset: quant.length)
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
          }
          return ScrollablePageStructure(
            headerSpace: Platform.isIOS ? 16 : 8,
            children: <Widget>[
              if (isSub(state.type))
                TextFieldFormatted(
                  focusNode: parentNameFocus,
                  controller: parentNameController,
                  readOnly: true,
                  enabled: true,
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
                    : nameController.text.contains(ravenNames) ||
                            state.metadataView != null
                        ? 'name not available'
                        : (isSub(state.type) && parentNameController.text == ''
                                ? _validateNameOnly(state)
                                : _validateName(state))
                            ? null
                            : '${isNFT(state.type) ? '1' : '3'}-${parentNameController.text == '' ? '30' : (30 - parentNameController.text.length).toString()} characters, special chars allowed: . _',
                onChanged: (String value) {
                  if (isSub(state.type)) {
                    if (value.length > 2 ||
                        (isNFT(state.type) && value.length > 0)) {
                      cubit.updateName(value);
                    } else {
                      cubit.update(name: value);
                    }
                  } else {
                    if (value.length > 2) {
                      cubit.updateName(value);
                    } else {
                      cubit.update(name: value);
                    }
                  }
                },
                onEditingComplete: () {
                  cubit.update(name: nameController.text);
                  FocusScope.of(context).requestFocus(quantityFocus);
                },
              ),
              TextFieldFormatted(
                focusNode: quantityFocus,
                controller: quantityController,
                textInputAction: TextInputAction.next,
                readOnly: isNFT(state.type),
                enabled: !isNFT(state.type),
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
                    : _validateQuantity(state)
                        ? null
                        : 'too large',
                onChanged: (String value) {
                  try {
                    cubit.update(quantityCoin: double.parse(value));
                  } catch (e) {
                    cubit.update(quantity: 0);
                  }
                },
                onEditingComplete: () {
                  if (_validateQuantity(state)) {
                    try {
                      cubit.update(
                          quantityCoin: double.parse(quantityController.text));
                    } catch (e) {
                      cubit.update(quantity: 0);
                    }
                  }

                  //// causes error on ios. as the keyboard becomes dismissed the bottom modal sheet is attempting to appear, they collide.
                  //FocusScope.of(context).requestFocus(sendFeeFocusNode);
                  FocusScope.of(context).unfocus();
                },
              ),
              TextFieldFormatted(
                onTap: isNFT(state.type)
                    ? null
                    : () => _produceDecimalsModal(cubit),
                focusNode: decimalsFocus,
                controller: decimalsController,
                readOnly: true,
                enabled: !isNFT(state.type),
                textInputAction: TextInputAction.next,
                labelText: 'Decimals',
                hintText: 'to how many decimal places is each coin divisible?',
                suffixIcon: isNFT(state.type)
                    ? null
                    : IconButton(
                        icon: Padding(
                            padding: const EdgeInsets.only(right: 14),
                            child: SvgPicture.asset(
                                'assets/icons/custom/black/chevron-down.svg')
                            //Icon(Icons.expand_more_rounded,
                            //    color: AppColors.black60)
                            ),
                        onPressed: () => _produceDecimalsModal(cubit)),
                onChanged: (String newValue) {
                  cubit.update(decimals: int.parse(decimalsController.text));
                  FocusScope.of(context).requestFocus(assetMemoFocus);
                },
              ),
              TextFieldFormatted(
                  focusNode: assetMemoFocus,
                  controller: assetMemoController,
                  textInputAction: TextInputAction.next,
                  labelText: 'Memo',
                  hintText: 'IPFS',
                  helperText: assetMemoFocus.hasFocus
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
                                onPressed: () async => cubit.update(
                                    assetMemo:
                                        (await Clipboard.getData('text/plain'))
                                                ?.text ??
                                            '')),*/
                  onChanged: (String value) => cubit.update(assetMemo: value),
                  onEditingComplete: () {
                    cubit.update(assetMemo: assetMemoController.text);
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
                        cubit.update(reissuable: value),
                  )),
            ],
            firstLowerChildren: <Widget>[
              BottomButton(
                enabled: _allValidation(state) && !clicked,
                focusNode: previewFocus,
                label: !clicked ? 'Preview' : 'Generating Transaction...',
                disabledOnPressed: () => _announceNoCoin(state),
                onPressed: () {
                  cubit.update(
                    parentName: parentNameController.text,
                    name: nameController.text,
                    assetMemo: assetMemoController.text,
                    quantityCoin: double.parse(quantityController.text),
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
        },
      ),
    );
  }

  bool _validateParentName(SimpleCreateFormState state, [String? parentName]) =>
      isSub(state.type)
          ? (parentName ?? parentNameController.text).isAssetPath
          : (parentName ?? parentNameController.text) == '';

  bool _validateName(SimpleCreateFormState state, [String? name]) {
    name = name ?? nameController.text;
    if (state.type == SymbolType.main) {
      return name.isMainAsset;
    }
    String fullname;
    if (state.type == SymbolType.restricted) {
      fullname = (r'$' + name);
    } else if (state.type == SymbolType.qualifier) {
      fullname = (r'#' + name);
    } else if (state.type == SymbolType.qualifierSub) {
      fullname = (parentNameController.text + '#' + name);
    } else if (state.type == SymbolType.sub) {
      fullname = (parentNameController.text + '/' + name);
    } else if (isNFT(state.type)) {
      fullname = (parentNameController.text + '#' + name);
    } else if (isChannel(state.type)) {
      fullname = (parentNameController.text + '~' + name);
    } else {
      fullname = name;
    }
    // catch all, this should never hit.
    return fullname.isAssetPath;
  }

  bool _validateNameOnly(SimpleCreateFormState state, [String? name]) {
    name = name ?? nameController.text;
    if (state.type == SymbolType.main) {
      return name.isAssetPath && name.isMainAsset;
    }
    if (state.type == SymbolType.restricted) {
      return name.isAssetPath && name.isRestricted;
    }
    if (state.type == SymbolType.qualifier) {
      return name.isAssetPath && name.isQualifier;
    }
    if (state.type == SymbolType.qualifierSub) {
      return name.isAssetPath && name.isSubQualifier;
    }
    if (state.type == SymbolType.sub) {
      return name.isAssetPath && name.isSubAsset;
    }
    if (isNFT(state.type)) {
      return name.length < 30 && name.isNFT;
    }
    if (isChannel(state.type)) {
      return name.length < 30 && name.isChannel;
    }
    // catch all, this should never hit.
    return name.isAssetPath;
  }

  bool _validateMemo([String? assetMemo]) =>
      (assetMemo ?? assetMemoController.text).isIpfs ||
      (assetMemo ?? assetMemoController.text).isMemo;

  bool _validateQuantity(SimpleCreateFormState state, [String? quantity]) {
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
      if (isNFT(state.type)) {
        return intQ == 1; // rvn && evr match?
      }
      return intQ <= coinsPerChain; // rvn && evr match?
    } catch (e) {
      return false;
    }
  }

  bool _allValidation(SimpleCreateFormState state) =>
      _validateParentName(state) &&
      _validateName(state) &&
      _validateQuantity(state) &&
      _validateMemo();

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
      //          state.assetMemo != '' &&
      //          state.assetMemo.isIpfs
      //      ? state.assetMemo
      //      : null,
      //  //TODO: Currently assetMemos are only for non-asset transactions
      //  assetMemo: state.security == pros.securities.currentCoin &&
      //          state.assetMemo != '' &&
      //          _validateMemo(state.assetMemo)
      //      ? state.assetMemo
      //      : null,
      //  note: state.note != '' ? state.note : null,
      //);
      _confirmSend(cubit);
    }
  }

  /// after transaction sent (and subscription on scripthash saved...)
  /// save the note with, no need to await:
  /// services.historyService.saveNote(hash, note {or history object})
  /// should notes be in a separate proclaim? makes this simpler, but its nice
  /// to have it all in one place as in transaction.note....

  void _confirmSend(SimpleCreateFormCubit cubit) async {
    await cubit.updateUnsignedTransaction(
      wallet: Current.wallet,
      chain: Current.chain,
      net: Current.net,
    );
    /*
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
    cubit.update(
        checkout: SimpleCreateCheckoutForm(
      symbol: cubit.state.name,
      displaySymbol: '',
      subSymbol: '',
      paymentSymbol: pros.securities.currentCoin.symbol,
      items: {
        'Quantity': cubit.state.quantity.toString(),
        'Decimal Places': cubit.state.decimals.toString(),
        if (!['', null].contains(cubit.state.assetMemo)) ...{
          'Memo': cubit.state.assetMemo
        },
        'Reissuable': cubit.state.reissuable ? 'yes' : 'no',
      },
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
        //assetMemo: Uint8List.fromList(cubit.state.assetMemo
        //    .codeUnits), // todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
        assetMemo: cubit.state.assetMemo, // todo: correct?assetMemo,
        creation: false,
      ),
    ));
    //streams.spend.estimate.add(SendEstimate(
    //  sendRequest.sendAmountAsSats,
    //  sendAll: sendRequest.sendAll,
    //  fees: 412000, // estimate. server doesn't tell us yet
    //  utxos: null, // in string form at cubit.state.unsigned.vinPrivateKeySource
    //  security: cubit.state.security,
    //  //assetMemo: Uint8List.fromList(cubit.state.assetMemo
    //  //    .codeUnits), // todo: correct? wait, we need more logic - if sending asset then assetMemo, else opreturnMemo below
    //  assetMemo: cubit.state.assetMemo, // todo: correct?assetMemo,
    //  creation: false,
    //));

    */
    setState(() => clicked = false);
    await cubit.sign();
    final validateMsg = await cubit.verifyTransaction();
    if (validateMsg.item1) {
      sail.to('/manage/create/checkout');
    } else {
      streams.app.behavior.snack.add(Snack(
          message: 'unable to generate transaction',
          positive: false,
          copy: validateMsg.item2,
          label: 'copy'));
    }
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
                cubit.update(parentName: sec.symbol);
                if (isSub(cubit.state.type) &&
                    (cubit.state.name.length > 2 ||
                        (isNFT(cubit.state.type) &&
                            cubit.state.name.length > 0))) {
                  cubit.updateName(cubit.state.name, parentName: sec.symbol);
                }
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
        Tuple2<String, int>('', 0),
        Tuple2<String, int>('.0', 1),
        Tuple2<String, int>('.00', 2),
        Tuple2<String, int>('.000', 3),
        Tuple2<String, int>('.0000', 4),
        Tuple2<String, int>('.00000', 5),
        Tuple2<String, int>('.000000', 6),
        Tuple2<String, int>('.0000000', 7),
        Tuple2<String, int>('.00000000', 8),
      ])
        ListTile(
          onTap: () {
            context.read<BottomModalSheetCubit>().hide();
            cubit.update(decimals: decimal.item2);
          },
          leading: components.icons.assetFromCacheOrGenerate(
              asset: decimal.item2.toString() + 'ABC',
              height: 24,
              width: 24,
              imageDetails: imageDetails,
              assetType: SymbolType.main),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                cubit.state.quantityCoin.toString(),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              Text(
                decimal.item1,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(color: AppColors.primary),
              ),
            ],
          ),
        )
    ]);
  }
}
