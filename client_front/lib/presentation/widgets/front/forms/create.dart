import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moontree_utils/moontree_utils.dart';
import 'package:wallet_utils/src/utilities/validation.dart';
import 'package:wallet_utils/src/utilities/validation_ext.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/services/transaction/maker.dart';
import 'package:client_back/streams/create.dart';
import 'package:client_front/presentation/components/components.dart';
import 'package:client_front/presentation/pages/misc/checkout.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/domain/utils/transformers.dart';
import 'package:client_front/presentation/widgets/widgets.dart';

enum FormPresets {
  // admin?
  // subAdmin?
  main,
  sub,
  restricted,
  qualifier,
  qualifierSub,
  unique,
  channel,
}

class CreateAsset extends StatefulWidget {
  static const int ipfsLength = 89;
  final FormPresets preset;
  final bool isSub;

  const CreateAsset({
    required this.preset,
    this.isSub = false,
  }) : super();

  @override
  _CreateAssetState createState() => _CreateAssetState();
}

class _CreateAssetState extends State<CreateAsset> {
  List<StreamSubscription<dynamic>> listeners = <StreamSubscription<dynamic>>[];
  GenericCreateForm? createForm;
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
  Map<FormPresets, String> presetToTitle = <FormPresets, String>{
    FormPresets.main: 'Asset Name',
    FormPresets.restricted: 'Restricted Asset Name',
    FormPresets.qualifier: 'Qualifier Name',
    FormPresets.unique: 'NFT Name',
    FormPresets.channel: 'Message Channel Name',
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
    listeners.add(streams.create.form.listen((GenericCreateForm? value) {
      if (createForm != value) {
        setState(() {
          createForm = value;
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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: body(),
    );
  }

  bool get isSub => widget.isSub;
  // parentController.text.length > 0;
  // above is shorthand, full logic:
  //    !isRestricted &&
  //    ((isNFT || isChannel) ||
  //        (isMain && widget.parent != null) ||
  //        (isQualifier && widget.parent != null));

  bool get isMain => widget.preset == FormPresets.main;
  bool get isNFT => widget.preset == FormPresets.unique;
  bool get isChannel => widget.preset == FormPresets.channel;
  bool get isQualifier => widget.preset == FormPresets.qualifier;
  bool get isRestricted => widget.preset == FormPresets.restricted;

  bool get needsParent => isSub && (isMain || isNFT || isChannel);
  bool get needsQualifierParent => isSub && isQualifier;
  bool get needsNFTParent => isNFT || isChannel;
  bool get needsQuantity => isMain || isRestricted || isQualifier;
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
                        if (needsParent || needsQualifierParent)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                            child: parentFeild,
                          ),
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
        labelText: 'Parent ${isQualifier ? 'Qualifier' : 'Asset'}',
        hintText: 'Parent ${isQualifier ? 'Qualifier' : 'Asset'}',
        errorText: parentValidationErr,
        suffixIcon: IconButton(
          icon: const Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
          onPressed: () => isQualifier
              ? _produceQualifierParentModal()
              : _produceParentModal(), // main subs, nft, channel
        ),
        onTap: () => isQualifier
            ? _produceQualifierParentModal()
            : _produceParentModal(), // main subs, nft, channel
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
        },
      );

  Widget get nameField => TextFieldFormatted(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      keyboardType: isRestricted ? TextInputType.none : null,
      inputFormatters: <TextInputFormatter>[MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textField(
        context,
        labelText: (isSub && !isNFT && !isChannel ? 'Sub ' : '') +
            presetToTitle[widget.preset]!,
        hintText: 'MOONTREE.COM',
        errorText: isChannel || isRestricted
            ? null
            : nameController.text.isNotEmpty && !nameValidated
                ? nameValidationErr
                : null,
      ),
      onTap: isRestricted ? _produceAdminAssetModal : null,
      onChanged:
          isRestricted ? null : (String value) => validateName(name: value),
      onEditingComplete: (isQualifier || isRestricted)
          ? () => FocusScope.of(context).requestFocus(quantityFocus)
          : (isNFT || isChannel)
              ? () => FocusScope.of(context).requestFocus(ipfsFocus)
              : () {
                  validateName();
                  if (nameValidated) {
                    FocusScope.of(context).requestFocus(quantityFocus);
                  }
                });

  Widget get quantityField => TextFieldFormatted(
        focusNode: quantityFocus,
        controller: quantityController,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          DecimalTextInputFormatter(
              decimalRange: int.parse(
                  decimalController.text == '' ? '0' : decimalController.text))
        ],
        labelText: 'Quantity',
        hintText: '21,000,000',
        errorText: quantityController.text != '' &&
                !quantityValidation(quantityController.text.toDouble())
            ? 'must ${quantityController.text.asSatsInt().toCommaString()} be between 1 and 21,000,000,000'
            : null,
        onChanged: (String value) =>
            validateQuantity(quantity: value == '' ? 0.0 : value.toDouble()),
        onEditingComplete: () {
          validateQuantity();
          formatQuantity();
          FocusScope.of(context)
              .requestFocus(isQualifier ? ipfsFocus : decimalFocus);
        },
      );

  Widget get decimalField => TextFieldFormatted(
        focusNode: decimalFocus,
        controller: decimalController,
        readOnly: true,
        labelText: 'Decimals',
        hintText: 'Decimals',
        suffixIcon: IconButton(
          icon: const Padding(
              padding: const EdgeInsets.only(right: 14),
              child: Icon(Icons.expand_more_rounded, color: Color(0xDE000000))),
          onPressed: () => _produceDecimalModal(),
        ),
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
      decoration: components.styles.decorations.textField(
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
        hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
        //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
        errorText: ipfsController.text == '' || ipfsValidated
            ? null
            : 'invalid IPFS/TXID',
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
                  streams.app.scrim.add(true);
                  return const AlertDialog(
                    content:
                        Text('Reissuable asset can increase in quantity and '
                            'decimal in the future.\n\nNon-reissuable '
                            'assets cannot be modified in anyway.'),
                  );
                },
              ).then((dynamic value) => streams.app.scrim.add(false)),
              icon: const Icon(
                Icons.help_rounded,
                color: Colors.black,
              ),
            ),
            Text('Reissuable', style: Theme.of(context).textTheme.bodyText1),
          ]),
          Switch(
            value: reissueValue,
            activeColor: Theme.of(context).backgroundColor,
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

  bool nameValidation(String name) {
    final bool validName = nameLengthValid(name) && nameTypeValid(name);
    nameValidationErr = validName ? null : nameValidationErr;
    return validName;
  }

  Future<bool> nameNotTakenValid(String name) async {
    final bool ret = !(await services.client.api.getAssetNames(name))
        .toList()
        .contains(name);
    if (!ret) {
      nameValidationErr = 'not available';
    }
    return ret;
  }

  bool nameTypeValid(String name) {
    if (isMain && !name.isMainAsset) {
      nameValidationErr = 'invalid Main';
      return false;
    }
    if (isNFT && !name.isNFT) {
      nameValidationErr = 'invalid NFT';
      return false;
    }
    if (isChannel && !name.isChannel) {
      nameValidationErr = 'invalid Channel';
      return false;
    }
    if (isRestricted && !name.isRestricted) {
      nameValidationErr = 'invalid Restricted';
      return false;
    }
    if (isQualifier && !name.isQualifier) {
      nameValidationErr = 'invalid Qualifier';
      return false;
    }
    if (isSub && isQualifier && !name.isSubQualifier) {
      nameValidationErr = 'invalid Sub Qualifier';
      return false;
    }
    if (isSub && !name.isSubAsset) {
      nameValidationErr = 'invalid SubAsset';
      return false;
    }
    return true;
  }

  bool nameLengthValid(String name) {
    if (!(name.length > 2 && name.length <= remainingNameLength)) {
      nameValidationErr = '${remainingNameLength - nameController.text.length}';
      return false;
    }
    return true;
  }

  Future<void> validateName({String? name}) async {
    name = name ?? nameController.text;
    final bool oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (nameValidated) {
      nameValidated = await nameNotTakenValid(fullName(true));
    }
    if (oldValidation != nameValidated) {
      setState(() {});
    }
  }

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

  bool assetDataValidation(String data) => data.isAssetData;

  void validateAssetData({String? data}) {
    data = data ?? ipfsController.text;
    final bool oldValidation = ipfsValidated;
    ipfsValidated = assetDataValidation(data);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() {});
    }
  }

  bool quantityValidation(double quantity) =>
      quantityController.text != '' && quantity.isRVNAmount;

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
      decimalController.text != '' && decimal >= 0 && decimal <= 8;

  void validateDecimal({int? decimal}) {
    decimal = decimal ?? decimalController.text.asSatsInt();
    final bool oldValidation = decimalValidated;
    decimalValidated = decimalValidation(decimal);
    if (oldValidation != decimalValidated || !decimalValidated) {
      setState(() {});
    }
  }

  bool get enabled =>
      nameValidated &&
      //nameValidation(nameController.text) &&
      (!needsQuantity ||
          quantityController.text != '' &&
              quantityValidation(quantityController.text.toDouble())) &&
      (!needsDecimal ||
          decimalController.text != '' &&
              decimalValidation(decimalController.text.asSatsInt())) &&
      (ipfsController.text == '' || assetDataValidation(ipfsController.text));

  Future<bool> get enabledAsync async => nameController.text.length > 2 &&
          nameValidation(nameController.text) &&
          await nameNotTakenValid(nameController.text) &&
          (!needsQuantity ||
              quantityController.text != '' &&
                  quantityValidation(quantityController.text.toDouble())) &&
          (!needsDecimal ||
              decimalController.text != '' &&
                  decimalValidation(decimalController.text.asSatsInt())) &&
          isNFT
      ? assetDataValidation(ipfsController.text)
      : (ipfsController.text == '' || assetDataValidation(ipfsController.text));

  Future<void> submit() async {
    if (await enabledAsync) {
      FocusScope.of(context).unfocus();

      /// send them to transaction checkout screen
      checkout(GenericCreateRequest(
        isSub: widget.isSub,
        isMain: isMain,
        isNFT: isNFT,
        isChannel: isChannel,
        isQualifier: isQualifier,
        isRestricted: isRestricted,
        fullName: fullName(true),
        wallet: Current.wallet,
        name: nameController.text,
        quantity: needsQuantity ? quantityController.text.toDouble() : null,
        assetData: ipfsController.text == ''
            ? null
            : (ipfsController.text.isIpfs
                ? ipfsController.text.base58Decode
                : ipfsController.text.hexBytesForScript),
        decimals: needsDecimal ? decimalController.text.asSatsInt() : null,
        reissuable: needsReissue ? reissueValue : null,
        verifier: needsVerifier ? verifierController.text : null,
        parent: isSub ? parentController.text : null,
      ));
    }
  }

  String fullName([bool full = false]) => (isSub && full)
      ? parentController.text +
          (isNFT ? '#' : (isChannel ? '~' : (isQualifier ? '/#' : '/'))) +
          nameController.text
      : ((isQualifier || isNFT)
              ? '#'
              : (isChannel ? '~' : (isRestricted ? r'$' : ''))) +
          nameController.text;

  void checkout(GenericCreateRequest createRequest) {
    /// send request to the correct stream
    streams.create.request.add(createRequest);

    /// go to confirmation page
    Navigator.of(components.routes.routeContext!).pushNamed(
      '/create/checkout',
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
            if (isNFT)
              <String>['NFT', '5']
            else
              isChannel
                  ? <String>['Message Channel', '100']
                  : isQualifier && isSub
                      ? <String>['Sub Qualifier Asset', '100']
                      : isSub
                          ? <String>['Sub Asset', '100']
                          : isMain
                              ? <String>['Main Asset', '500']
                              : isQualifier
                                  ? <String>['Qualifier Asset', '1000']
                                  : isRestricted
                                      ? <String>['Restricted Asset', '1500']
                                      : <String>['Asset', '500']
          ],
          total: 'calculating total...',
          // produce transaction structure here and the checkout screen will
          // send it up on submit:
          buttonAction: () =>
              streams.create.send.add(streams.create.made.value),
          buttonWord: 'Create',
          loadingMessage: 'Creating Asset',
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

  void _produceQualifierParentModal() {
    SelectionItems(context, modalSet: SelectionSet.Parents).build(
        holdingNames:
            Current.qualifierNames.map((String name) => name).toList());
  }

  void _produceDecimalModal() {
    SelectionItems(context, modalSet: SelectionSet.Decimal)
        .build(decimalPrefix: quantityController.text.split('.').first);
  }

  void _produceAdminAssetModal() {
    SelectionItems(context, modalSet: SelectionSet.Admins).build(
        holdingNames: Current.adminNames
            .where((String name) => !name.contains('/'))
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }
}
