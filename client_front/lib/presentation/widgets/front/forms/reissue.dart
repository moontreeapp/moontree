/*
/// make name static, make decimals static if at max, make quantity static if at max,
/// limit quantity to not go lower than itself
/// limit decimals to not go lower than itself
/// allow for new ipfs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:wallet_utils/src/utilities/validation.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_front/presentation/components/styles/styles.dart'
    as styles;
import 'package:client_front/presentation/components/components.dart'
    as components;
//import 'package:client_front/presentation/pagesv1/misc/checkout.dart';
import 'package:client_front/presentation/pages/wallet/checkout.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_back/streams/reissue.dart';
import 'package:client_front/domain/utils/transformers.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

class ReissueAsset extends StatefulWidget {
  static const int ipfsLength = 89;
  final FormPresets preset;
  final bool isSub;

  const ReissueAsset({
    required this.preset,
    this.isSub = false,
  }) : super();

  @override
  _ReissueAssetState createState() => _ReissueAssetState();
}

class _ReissueAssetState extends State<ReissueAsset> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  GenericReissueForm? reissueForm;
  TextEditingController parentController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  TextEditingController verifierController = TextEditingController();
  bool reissueValue = true;
  FocusNode parentFocus = FocusNode();
  FocusNode nameFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  FocusNode verifierFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  String? nameValidationErr;
  String? parentValidationErr;
  bool verifierValidated = false;
  String? verifierValidationErr;
  int remainingNameLength = 30;
  int remainingVerifierLength = 89;
  double minQuantity = 0;
  int minDecimal = 0;
  String minIpfs = '';
  Map<FormPresets, String> presetToTitle = <FormPresets, String>{
    FormPresets.main: 'Reissue',
    FormPresets.restricted: 'Reissue',
  };

  String limitQ(String q, String d) {
    if (q.contains('.')) {
      final List<String> splits = q.split('.');
      final int maxd = int.parse(d);
      if (splits[1].length > maxd) {
        return '${splits.first}.${splits[1].substring(0, maxd)}';
      }
    }
    return q;
  }

  @override
  void initState() {
    super.initState();
    listeners.add(streams.reissue.form.listen((GenericReissueForm? value) {
      if (reissueForm != value) {
        setState(() {
          reissueForm = value;
          parentController.text = value?.parent ?? parentController.text;
          nameController.text = value?.name ?? nameController.text;
          ipfsController.text = value?.ipfs ?? ipfsController.text;
          decimalController.text =
              (value?.decimal ?? decimalController.text).toString();
          quantityController.text = limitQ(
              value?.quantity?.toSatsCommaString() ?? quantityController.text,
              decimalController.text);
          reissueValue = value?.reissuable ?? reissueValue;
          verifierController.text = value?.verifier ?? verifierController.text;
          minQuantity = value?.minQuantity ?? 0.0;
          minDecimal = value?.minDecimal ?? 0;
          minIpfs = value?.minIpfs ?? '';
          validateAssetData(data: minIpfs);
        });
      }
    }));
  }

  @override
  void dispose() {
    parentFocus.dispose();
    nameController.dispose();
    ipfsController.dispose();
    quantityController.dispose();
    decimalController.dispose();
    nameFocus.dispose();
    ipfsFocus.dispose();
    nextFocus.dispose();
    quantityFocus.dispose();
    decimalFocus.dispose();
    verifierController.dispose();
    verifierFocus.dispose();
    for (final StreamSubscription<dynamic> listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    remainingNameLength =
        // max asset length
        maxNameLength -
            // parent text and implied '/'
            (isSub ? parentController.text.length + 1 : 0) -
            // everything else has a special character denoting its type
            (isMain ? 0 : 1);
    decimalController.text = decimalController.text == '' ||
            decimalController.text.toDouble() < minDecimal
        ? minDecimal.toString()
        : decimalController.text;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  bool get isSub => widget.isSub;
  bool get isMain => widget.preset == FormPresets.main;
  bool get isRestricted => widget.preset == FormPresets.restricted;
  bool get needsParent => isSub && isMain;
  bool get needsQuantity => isMain || isRestricted;
  bool get needsDecimal => isMain || isRestricted;
  bool get needsVerifier => isRestricted;
  bool get needsReissue => isMain || isRestricted;

  Widget body() => CustomScrollView(
          // solves scrolling while keyboard
          shrinkWrap: true,
          slivers: <Widget>[
            SliverToBoxAdapter(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: nameField,
                        ),
                        if (needsQuantity)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: quantityField,
                          ),
                        if (needsDecimal)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: decimalField,
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: ipfsField,
                        ),
                        if (needsVerifier)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: verifierField,
                          ),
                        if (needsReissue)
                          Padding(
                              padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: reissueRow),
                      ]),
                ])),
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding:
                        const EdgeInsets.only(bottom: 40, left: 16, right: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        Row(children: <Widget>[submitButton])
                      ],
                    )))
          ]);

  Widget get parentFeild => TextFieldFormatted(
        focusNode: parentFocus,
        controller: parentController,
        readOnly: true,
        labelText: 'Parent Asset',
        hintText: 'Parent Asset',
        errorText: parentValidationErr,
        suffixIcon: IconButton(
          icon: const Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
          onPressed: () => _produceParentModal(), // main subs, nft, channel
        ),
        onTap: () => _produceParentModal(), // main subs, nft, channel
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
        },
      );

  Widget get nameField => TextFieldFormatted(
      focusNode: nameFocus,
      autocorrect: false,
      enabled: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      keyboardType: isRestricted ? TextInputType.none : null,
      inputFormatters: <TextInputFormatter>[MainAssetNameTextFormatter()],
      decoration: styles.decorations.textField(
        context,
        labelText: (isSub ? 'Sub ' : '') + presetToTitle[widget.preset]!,
        hintText: 'MOONTREE.COM',
      ),
      onTap: isRestricted ? _produceAdminAssetModal : null,
      onEditingComplete: isRestricted
          ? () => FocusScope.of(context).requestFocus(quantityFocus)
          : () {
              FocusScope.of(context).requestFocus(quantityFocus);
            });

  Widget get quantityField => TextFieldFormatted(
        focusNode: quantityFocus,
        controller: quantityController,
        enabled: minQuantity != coinsPerChain,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(decimalRange: minDecimal)
        ],
        labelText: 'Additional Quantity',
        hintText: '21,000,000',
        errorText: quantityController.text != '' &&
                !quantityValidation(quantityController.text.toDouble())
            ? 'Additional Quantity cannot exceed ${coinsPerChain - minQuantity}'
            : null,
        onChanged: (String value) =>
            validateQuantity(quantity: value == '' ? 0.0 : value.toDouble()),
        onEditingComplete: () {
          validateQuantity();
          formatQuantity();
          FocusScope.of(context).requestFocus(decimalFocus);
          setState(() {});
        },
      );

  Widget get decimalField => TextFieldFormatted(
        focusNode: decimalFocus,
        controller: decimalController, // cannot be lower than minDecimal
        readOnly: true,
        labelText: 'Decimals',
        hintText: 'Decimals',
        suffixIcon: IconButton(
          icon: const Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
          onPressed: minDecimal == 8 ? () {} : () => _produceDecimalModal(),
        ),
        onTap: minDecimal == 8 ? () {} : () => _produceDecimalModal(),
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
        },
      );

  Widget get verifierField => TextFieldFormatted(
      focusNode: verifierFocus,
      autocorrect: false,
      controller: verifierController,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[VerifierStringTextFormatter()],
      decoration: styles.decorations.textField(
        context,
        labelText: 'Verifier String',
        hintText: '((#KYC & #ACCREDITED) | #EXEMPT) & !#IRS',
        errorText: verifierController.text.length > 2 &&
                !verifierValidation(verifierController.text)
            ? verifierValidationErr
            : null,
      ),
      onChanged: (String value) => validateVerifier(verifier: value),
      onEditingComplete: () {
        validateVerifier();
        FocusScope.of(context).requestFocus(ipfsFocus);
      });

  Widget get ipfsField => TextFieldFormatted(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        labelText: 'IPFS/TXID',
        hintText: minIpfs == ''
            ? 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr'
            : minIpfs,
        //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
        //errorText: ipfsController.text == '' || ipfsValidated
        //    ? null
        //    : 'Invalid IPFS',
        errorText: ipfsController.text == ''
            ? (minIpfs == '' ? null : 'You must input an IPFS/TXID')
            : ipfsValidated
                ? null
                : 'Invalid IPFS/TXID',
        onChanged: (String value) => validateAssetData(data: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

  Widget get reissueRow => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(children: <Widget>[
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) {
                  streams.app.behavior.scrim.add(true);
                  return const AlertDialog(
                    content:
                        Text('Reissuable asset can increase in quantity and '
                            'decimal in the future.\n\nNon-reissuable '
                            'assets cannot be modified in anyway.'),
                  );
                },
              ).then((dynamic value) => streams.app.behavior.scrim.add(false)),
              icon: const Icon(
                Icons.help_rounded,
                color: Colors.black,
              ),
            ),
            Text('Reissuable', style: Theme.of(context).textTheme.bodyLarge),
          ]),
          Switch(
            value: reissueValue,
            activeColor: Theme.of(context).colorScheme.background,
            onChanged: (bool value) {
              setState(() {
                reissueValue = value;
              });
            },
          )
        ],
      );

  Widget get submitButton => components.buttons.actionButton(
        context,
        focusNode: nextFocus,
        enabled: enabled,
        onPressed: submit,
      );

  bool verifierValidation(String verifier) {
    if (verifier.length > remainingVerifierLength) {
      verifierValidationErr =
          '${remainingVerifierLength - verifierController.text.length}';
      return false;
      //} else if (verifier.endsWith('.') || verifier.endsWith('_')) {
      //  verifierValidationErr = 'allowed characters: A-Z, 0-9, (._#&|!)';
      //  ret = false;
    } else if ('('.allMatches(verifier).length !=
        ')'.allMatches(verifier).length) {
      verifierValidationErr =
          '${'('.allMatches(verifier).length} open parenthesis, '
          '${')'.allMatches(verifier).length} closed parenthesis';
      return false;
    }
    verifierValidationErr = null;
    return true;
  }

  void validateVerifier({String? verifier}) {
    verifier = verifier ?? verifierController.text;
    final bool oldValidation = verifierValidated;
    verifierValidated = verifierValidation(verifier);
    if (oldValidation != verifierValidated || !verifierValidated) {
      setState(() {});
    }
  }

  bool assetDataValidation(String ipfs) => ipfs.isAssetData;

  void validateAssetData({String? data}) {
    data = data ?? ipfsController.text;
    final bool oldValidation = ipfsValidated;
    ipfsValidated = assetDataValidation(data);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() {});
    }
  }

  bool quantityValidation(double quantity) =>
      quantityController.text != '' && (minQuantity + quantity).isRVNAmount;

  void validateQuantity({double? quantity}) {
    quantity = quantity ??
        (quantityController.text == '' ? '0' : quantityController.text)
            .toDouble();
    final bool oldValidation = quantityValidated;
    quantityValidated = quantityValidation(quantity);
    if (oldValidation != quantityValidated || !quantityValidated) {
      setState(() {});
    }
  }

  bool decimalValidation(int decimal) =>
      decimalController.text != '' && decimal >= minDecimal && decimal <= 8;

  void validateDecimal({int? decimal}) {
    decimal = decimal ?? decimalController.text.asSatsInt();
    final bool oldValidation = decimalValidated;
    decimalValidated = decimalValidation(decimal);
    if (oldValidation != decimalValidated || !decimalValidated) {
      setState(() {});
    }
  }

  bool get enabled =>
      // If we change anything
      ((quantityController.text != '' &&
              quantityController.text.toDouble() != 0.0) ||
          decimalController.text != minDecimal.toString() ||
          reissueValue == false ||
          (minIpfs != ipfsController.text)) &&
      // Don't enable if invalid state
      ((minIpfs == ''
              ? (ipfsController.text == ''
                  ? true
                  : assetDataValidation(ipfsController.text))
              : (ipfsController.text != '' &&
                  assetDataValidation(ipfsController.text))) &&
          (quantityController.text == '' ||
              quantityValidation(quantityController.text.toDouble())) &&
          decimalValidation(decimalController.text.asSatsInt()));

  /*[
        quantityController.text != '' &&
            quantityValidation(double.parse(quantityController.text)),
        decimalController.text != minDecimal.toString() &&
            decimalValidation(decimalController.text.asSatsInt()),
        ipfsController.text != '' && ipfsValidation(ipfsController.text),
        reissueValue == false,
      ].any((e) => e);
*/

  Future<void> submit() async {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// send them to transaction checkout screen
      checkout(GenericReissueRequest(
        isSub: widget.isSub,
        isMain: isMain,
        isRestricted: isRestricted,
        fullName: fullName(true),
        wallet: Current.wallet,
        name: nameController.text,
        quantity: needsQuantity
            ? (quantityController.text == ''
                ? null
                : quantityController.text.toDouble())
            : null,
        decimals: needsDecimal ? decimalController.text.asSatsInt() : null,
        originalQuantity: minQuantity,
        originalDecimals: minDecimal,
        originalAssetData: minIpfs == ''
            ? null
            : (minIpfs.isIpfs
                ? minIpfs.base58Decode
                : minIpfs.hexBytesForScript),
        assetData: ipfsController.text == ''
            ? null
            : (ipfsController.text.isIpfs
                ? ipfsController.text.base58Decode
                : ipfsController.text.hexBytesForScript),
        reissuable: needsReissue ? reissueValue : null,
        verifier: needsVerifier ? verifierController.text : null,
        parent: isSub ? parentController.text : null,
      ));
    }
  }

  String fullName([bool full = false]) => (isSub && full)
      ? '${parentController.text}/${nameController.text}'
      : nameController.text;

  void checkout(GenericReissueRequest reissueRequest) {
    /// send request to the correct stream
    streams.reissue.request.add(reissueRequest);

    /// go to confirmation page
    Navigator.of(components.routes.routeContext!).pushNamed(
      '/reissue/checkout',
      arguments: <String, CheckoutStruct>{
        'struct': CheckoutStruct(
          /// full symbol name
          symbol: fullName(true),
          displaySymbol: nameController.text,
          subSymbol: '',
          paymentSymbol: pros.securities.currentCoin.symbol,
          items: <Iterable<String>>[
            /// send the correct items
            if (isSub) <String>['Name', fullName(true), '2'],
            if (!isSub) <String>['Name', fullName(), '2'],
            if (needsQuantity) <String>['Quantity', quantityController.text],
            if (needsDecimal) <String>['Decimals', decimalController.text],
            if (ipfsController.text != '')
              <String>['IPFS/Txid', ipfsController.text, '9'],
            if (needsVerifier)
              <String>['Verifier String', verifierController.text, '6'],
            if (needsReissue)
              <String>['Reissuable', if (reissueValue) 'Yes' else 'No', '3'],
          ],
          fees: <Iterable<String>>[
            // Standard / Fast transaction, will pull from settings?
            <String>['Standard Transaction', 'calculating fee...'],
            if (isSub)
              <String>['Reissue', '100']
            else
              isMain
                  ? <String>['Reissue', '100']
                  : isRestricted
                      ? <String>['Reissue', '100']
                      : <String>['Reissue', '100']
          ],
          total: 'calculating total...',
          // produce transaction structure here and the checkout screen will
          // send it up on submit:
          buttonAction: () =>
              streams.reissue.send.add(streams.reissue.made.value),
          buttonWord: 'Reissue',
          loadingMessage: 'Reissuing Asset',
        )
      },
    );
  }

  void formatQuantity() =>
      quantityController.text = quantityController.text.isInt
          ? quantityController.text.asSatsInt().toCommaString()
          : quantityController.text.toDouble().toSatsCommaString();

  void _produceParentModal() {
    SelectionItems(context, modalSet: SelectionSet.Parents).build(
        holdingNames: Current.adminNames
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }

  void _produceDecimalModal() {
    SelectionItems(context, modalSet: SelectionSet.Decimal).build(
        decimalPrefix: quantityController.text.split('.').first,
        minDecimal: minDecimal);
  }

  void _produceAdminAssetModal() {
    SelectionItems(context, modalSet: SelectionSet.Admins).build(
        holdingNames: Current.adminNames
            .where((String name) => !name.contains('/'))
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }
}
*/