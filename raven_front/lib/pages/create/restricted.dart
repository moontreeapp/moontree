import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/services/lookup.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/params.dart';
import 'package:raven_back/utils/utilities.dart';
import 'package:raven_back/streams/create.dart';
import 'package:raven_front/utils/transformers.dart';
import 'package:raven_front/widgets/widgets.dart';

class RestrictedCreate extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  @override
  _RestrictedCreateState createState() => _RestrictedCreateState();
}

class _RestrictedCreateState extends State<RestrictedCreate> {
  List<StreamSubscription> listeners = [];
  GenericCreateForm? createForm;
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  TextEditingController verifierController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  bool reissueValue = true;
  FocusNode nameFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  FocusNode verifierFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  bool verifierValidated = false;
  String? verifierValidationErr;
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
    quantityController.dispose();
    decimalController.dispose();
    verifierController.dispose();
    ipfsController.dispose();
    nameFocus.dispose();
    quantityFocus.dispose();
    decimalFocus.dispose();
    verifierFocus.dispose();
    ipfsFocus.dispose();
    nextFocus.dispose();
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
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: quantityField(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: decimalField(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: verifierField(),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
                          child: ipfsField(),
                        ),
                        //reissueSwitch,
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
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Restricted Asset Name',
        hintText: 'MOONTREE_WALLET.COM',
      ),
      onTap: _produceAdminAssetModal,
      //onChanged: (String value) => validateName(name: value),
      onEditingComplete: () {
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
        ], // Only numbers can be entered
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Quantity',
          hintText: '21,000,000',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: quantityController.text != '' &&
                  !quantityValidation(quantityController.text.toInt())
              ? 'must ${quantityController.text.toInt().toCommaString()} be between 1 and 21,000,000'
              : null,
        ),
        onChanged: (String value) => validateQuantity(quantity: value.toInt()),
        onEditingComplete: () =>
            FocusScope.of(context).requestFocus(decimalFocus),
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
              ? '${RestrictedCreate.ipfsLength - ipfsController.text.length}'
              : null,
        ),
        onChanged: (String value) => validateIPFS(ipfs: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

  Widget reissueSwitch() => SwitchListTile(
        title: Text('Reissuable', style: Theme.of(context).switchText),
        value: reissueValue,
        activeColor: Theme.of(context).backgroundColor,
        onChanged: (bool value) {
          setState(() {
            reissueValue = value;
          });
        },
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

  bool ipfsValidation(String ipfs) =>
      ipfs.length <= RestrictedCreate.ipfsLength;

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
      quantity <= RestrictedCreate.quantityMax &&
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
      verifierValidation(verifierController.text) &&
      quantityController.text != '' &&
      quantityValidation(quantityController.text.toInt()) &&
      decimalController.text != '' &&
      decimalValidation(decimalController.text.toInt()) &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// make the send request
      var createRequest = RestrictedCreateRequest(
        name: nameController.text,
        verifier: verifierController.text,
        ipfs: ipfsController.text,
        quantity: 0,
        decimals: 0,
        reissuable: reissueValue,
      );

      /// send them to transaction checkout screen
      confirmSend(createRequest);
    }
  }

  void confirmSend(RestrictedCreateRequest createRequest) {
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
            ['Restricted Asset Name', nameController.text, '2'],
            ['Quantity', quantityController.text],
            ['Decimals', decimalController.text],
            ['Verifier String', verifierController.text, '6'],
            ['IPFS/Txid', ipfsController.text, '9'],
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

          /// send the RestrictedCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
          buttonWord: 'Send',
        )
      },
    );
  }

  void _produceAdminAssetModal() {
    SelectionItems(context, modalSet: SelectionSet.Admins).build(
        holdingNames: Current.adminNames
            .map((String name) => name.replaceAll('!', ''))
            .toList());
  }
}
