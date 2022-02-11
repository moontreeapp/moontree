import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:mockito/mockito.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_back/utils/utilities.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/utils/transformers.dart';
import 'package:raven_front/widgets/widgets.dart';

enum FormPresets {
  main,
  sub,
  restricted,
  qualifier,
  subQualifier,
  NFT,
  channel,
}

class CreateSomething extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  late FormPresets preset;
  late String nameTitle;
  late int remainingNameLength;

  CreateSomething({
    required this.preset,
    String? nameTitle,
    int? nameLength,
    // should we get parent here or from the stream ??
    // if main or qualifier and if parent present we know it's a sub
    // if nft or channel we know it's a sub.
    // we could have the parent in the stream but only look if we get a flag
    // or if it's an nft or channel. that might be best.
  }) : super() {
    var presets = {
      FormPresets.main: {
        'name': 'Asset Name',
        'nameLength': 31,
      },
      FormPresets.sub: {
        'name': 'Sub Asset Name',
        'nameLength': 27,
      },
      FormPresets.restricted: {
        'name': 'Restricted Asset Name',
        'nameLength': 30,
      },
      FormPresets.qualifier: {
        'name': 'Qualifier Name',
        'nameLength': 30,
      },
      FormPresets.subQualifier: {
        'name': 'Sub Qualifier Name',
        'nameLength': 26,
      },
      FormPresets.NFT: {
        'name': 'NFT Name',
        'nameLength': 31,
      },
      FormPresets.channel: {
        'name': 'Message Channel Name',
        'nameLength': 31,
      },
    }[preset]!;
    this.nameTitle = nameTitle ?? presets['name']! as String;
    // highly dependant on if child logic...
    this.remainingNameLength = nameLength ?? presets['nameLength']! as int;
  }

  @override
  _CreateSomethingState createState() => _CreateSomethingState();
}

class _CreateSomethingState extends State<CreateSomething> {
  List<StreamSubscription> listeners = [];
  GenericCreateForm? createForm;
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  TextEditingController verifierController = TextEditingController();
  bool reissueValue = true;
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
  bool verifierValidated = false;
  String? verifierValidationErr;
  // if this is a sub asset...
  // we will have to get this depending on which asset/subasset/ we're using to
  // make the main, but the most it could possibly be is 27 because main asset
  // name is at least 3 characters plus / and the most is 31: RVN/27...
  int remainingNameLength = 31; //sub asset max length: 27;
  int remainingVerifierLength = 89;

  @override
  void initState() {
    super.initState();
    listeners.add(streams.create.form.listen((GenericCreateForm? value) {
      if (createForm != value) {
        setState(() {
          createForm = value;
          nameController.text = value?.name ?? nameController.text;
          ipfsController.text = value?.ipfs ?? ipfsController.text;
          quantityController.text =
              value?.quantity?.toString() ?? quantityController.text;
          decimalController.text = value?.decimal ?? decimalController.text;
          reissueValue = value?.reissuable ?? reissueValue;
          verifierController.text = value?.verifier ?? verifierController.text;
        });
      }
    }));
  }

  @override
  void dispose() {
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
    for (var listener in listeners) {
      listener.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  bool get needsQuantity => [
        FormPresets.main,
        FormPresets.restricted,
        FormPresets.qualifier
      ].contains(widget.preset);

  bool get needsDecimal =>
      [FormPresets.main, FormPresets.restricted].contains(widget.preset);

  bool get needsVerifier => [FormPresets.restricted].contains(widget.preset);

  bool get needsReissue =>
      [FormPresets.main, FormPresets.restricted].contains(widget.preset);

  bool get isQualifierOrRestircted =>
      [FormPresets.qualifier, FormPresets.restricted].contains(widget.preset);

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
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: nameField(),
                        ),
                        if (needsQuantity)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: quantityField(),
                          ),
                        if (needsDecimal)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: decimalField(),
                          ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: ipfsField(),
                        ),
                        if (needsVerifier)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: verifierField(),
                          ),
                        if (needsReissue)
                          Padding(
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 8),
                              child: reissueRow()),
                      ]),
                ])),
            SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                    padding: EdgeInsets.only(bottom: 40, left: 16, right: 16),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [submitButton()])))
          ]);

  Widget nameField() => TextField(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      inputFormatters: [MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: widget.nameTitle,
        hintText: 'MOONTREE_WALLET.COM',
        errorText: isQualifierOrRestircted
            ? null
            : nameController.text.length > 2 &&
                    !nameValidation(nameController.text)
                ? nameValidationErr
                : null,
      ),
      onChanged: isQualifierOrRestircted
          ? null
          : (String value) => validateName(name: value),
      onEditingComplete: isQualifierOrRestircted
          ? () => FocusScope.of(context).requestFocus(quantityFocus)
          : [FormPresets.NFT, FormPresets.channel].contains(widget.preset)
              ? () => FocusScope.of(context).requestFocus(ipfsFocus)
              : () {
                  nameController.text =
                      nameController.text.substring(0, remainingNameLength);
                  if (nameController.text.endsWith('_') ||
                      nameController.text.endsWith('.')) {
                    nameController.text = nameController.text
                        .substring(0, nameController.text.length - 1);
                  }
                  validateName();
                  FocusScope.of(context).requestFocus(quantityFocus);
                });

  Widget quantityField() => TextField(
        focusNode: quantityFocus,
        controller: quantityController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        inputFormatters: <TextInputFormatter>[
          FilteringTextInputFormatter.digitsOnly,
          CommaIntValueTextFormatter()
        ],
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Quantity',
          hintText: '21,000,000',
          errorText: quantityController.text != '' &&
                  !quantityValidation(quantityController.text.toInt())
              ? 'must ${quantityController.text.toInt().toCommaString()} be between 1 and 21,000,000'
              : null,
        ),
        onChanged: (String value) => validateQuantity(quantity: value.toInt()),
        onEditingComplete: () => FocusScope.of(context).requestFocus(
            widget.preset == FormPresets.qualifier ? ipfsFocus : decimalFocus),
      );

  Widget decimalField() => TextField(
        focusNode: decimalFocus,
        controller: decimalController,
        readOnly: true,
        decoration: components.styles.decorations.textFeild(context,
            labelText: 'Decimals',
            hintText: 'Decimals',
            suffixIcon: IconButton(
              icon: Padding(
                  padding: EdgeInsets.only(right: 14),
                  child: Icon(Icons.expand_more_rounded,
                      color: Color(0xDE000000))),
              onPressed: () => _produceFeeModal(),
            )),
        onTap: () {
          _produceFeeModal();
        },
        onChanged: (String? newValue) {
          FocusScope.of(context).requestFocus(ipfsFocus);
          setState(() {});
        },
      );

  Widget verifierField() => TextField(
      focusNode: verifierFocus,
      autocorrect: false,
      controller: verifierController,
      textInputAction: TextInputAction.done,
      inputFormatters: [VerifierStringTextFormatter()],
      decoration: components.styles.decorations.textFeild(
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

  Widget ipfsField() => TextField(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'IPFS/Txid',
          hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: !ipfsValidation(ipfsController.text)
              ? '${CreateSomething.ipfsLength - ipfsController.text.length}'
              : null,
        ),
        onChanged: (String value) => validateIPFS(ipfs: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

  Widget reissueRow() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
              onPressed: () => showDialog(
                context: context,
                builder: (BuildContext context) => AlertDialog(
                  content: Text('Reissuable asset can increase in quantity and '
                      'decimal in the future.\n\nNon-reissuable '
                      'assets cannot be modified in anyway.'),
                ),
              ),
              icon: const Icon(
                Icons.help_rounded,
                color: Colors.black,
              ),
            ),
            Text('Reissuable', style: Theme.of(context).switchText),
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

  Widget submitButton() => Container(
      height: 40,
      child: OutlinedButton.icon(
          focusNode: nextFocus,
          onPressed: enabled ? () => submit() : () {},
          icon: Icon(
            Icons.chevron_right_rounded,
            color: enabled ? null : Color(0x61000000),
          ),
          label: Text(
            'NEXT',
            style: enabled
                ? Theme.of(context).enabledButton
                : Theme.of(context).disabledButton,
          ),
          style: components.styles.buttons.bottom(
            context,
            disabled: !enabled,
          )));

  void _produceFeeModal() {
    SelectionItems(context, modalSet: SelectionSet.Decimal)
        .build(decimalPrefix: quantityController.text);
  }

  bool nameValidation(String name) {
    if (!(name.length > 2 && name.length <= remainingNameLength)) {
      nameValidationErr = '${remainingNameLength - nameController.text.length}';
      return false;
    } else if (name.endsWith('.') || name.endsWith('_')) {
      nameValidationErr = 'cannot end with special character';
      return false;
    }
    nameValidationErr = null;
    return true;
  }

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated || !nameValidated) {
      setState(() => {});
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
    var oldValidation = verifierValidated;
    verifierValidated = verifierValidation(verifier);
    if (oldValidation != verifierValidated || !verifierValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs.length <= CreateSomething.ipfsLength;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() => {});
    }
  }

  bool quantityValidation(int quantity) =>
      quantityController.text != '' &&
      quantity <= CreateSomething.quantityMax &&
      quantity > 0;

  void validateQuantity({int? quantity}) {
    quantity = quantity ?? quantityController.text.toInt();
    var oldValidation = quantityValidated;
    quantityValidated = quantityValidation(quantity);
    if (oldValidation != quantityValidated || !quantityValidated) {
      setState(() => {});
    }
  }

  bool decimalValidation(int decimal) =>
      decimalController.text != '' && decimal >= 0 && decimal <= 8;

  void validateDecimal({int? decimal}) {
    decimal = decimal ?? decimalController.text.toInt();
    var oldValidation = decimalValidated;
    decimalValidated = decimalValidation(decimal);
    if (oldValidation != decimalValidated || !decimalValidated) {
      setState(() => {});
    }
  }

  bool get enabled =>
      nameController.text.length > 2 &&
      nameValidation(nameController.text) &&
      (needsQuantity
          ? quantityController.text != '' &&
              quantityValidation(quantityController.text.toInt())
          : true) &&
      (needsDecimal
          ? decimalController.text != '' &&
              decimalValidation(decimalController.text.toInt())
          : true) &&
      (widget.preset == FormPresets.NFT ? ipfsController.text != '' : true) &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// send them to transaction checkout screen
      checkout(GenericCreateRequest(
        name: nameController.text,
        ipfs: ipfsController.text,
        quantity: needsQuantity ? quantityController.text.toInt() : null,
        decimals: needsDecimal ? decimalController.text.toInt() : 0,
        reissuable: needsReissue ? reissueValue : null,
        verifier: needsVerifier ? verifierController.text : null,
        // only on all NFTs, all channels, mains if sub, qualifiers if sub,
        parent: 'PARENT/ASSET/PATH/#',
      ));
    }
  }

  void checkout(GenericCreateRequest createRequest) {
    /// send request to the correct stream
    //streams.spend.make.add(createRequest);

    /// go to confirmation page
    Navigator.of(components.navigator.routeContext!).pushNamed(
      '/transaction/checkout',
      arguments: {
        'struct': CheckoutStruct(
          /// get the name we're creating the Asset under
          //symbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
          //        ? 'RVN'
          //        : streams.spend.form.value?.symbol) ??
          //    'RVN'),
          subSymbol: '',
          paymentSymbol: 'RVN',
          items: [
            /// send the correct items
            ['Parent', 'PARENT/ASSET/PATH/#', '2'],
            ['Asset Name', nameController.text, '2'],
            if (needsQuantity) ['Quantity', quantityController.text],
            if (needsDecimal) ['Decimals', decimalController.text],
            ['IPFS/Txid', ipfsController.text, '9'],
            if (needsVerifier)
              ['Verifier String', verifierController.text, '6'],
            if (needsReissue)
              [
                'Reissuable',
                reissueValue
                    ? 'Yes'
                    : 'NO  (WARNING: These settings will be PERMANENT forever!)',
                '3'
              ],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () => null,

          /// send the MainCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
          buttonWord: 'Create',
        )
      },
    );
  }
}
