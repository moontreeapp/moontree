import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
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

class MainCreate extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  @override
  _MainCreateState createState() => _MainCreateState();
}

class _MainCreateState extends State<MainCreate> {
  List<StreamSubscription> listeners = [];
  GenericCreateForm? createForm;
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  bool reissueValue = true;
  FocusNode nameFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  String? nameValidationErr;
  // if this is a sub asset...
  // we will have to get this depending on which asset/subasset/ we're using to
  // make the main, but the most it could possibly be is 27 because main asset
  // name is at least 3 characters plus / and the most is 31: RVN/27...
  int remainingNameLength = 31; //sub asset max length: 27;

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
        });
      }
    }));
  }

  @override
  void dispose() {
    nameController.dispose();
    ipfsController.dispose();
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
      inputFormatters: [MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Asset Name',
        hintText: 'MOONTREE_WALLET.COM',
        errorText: nameController.text.length > 2 &&
                !nameValidation(nameController.text)
            ? nameValidationErr
            : null,
      ),
      onChanged: (String value) => validateName(name: value),
      onEditingComplete: () {
        nameController.text =
            nameController.text.substring(0, remainingNameLength);
        if (nameController.text.endsWith('_') ||
            nameController.text.endsWith('.')) {
          nameController.text =
              nameController.text.substring(0, nameController.text.length - 1);
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
        ], // Only numbers can be entered
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'Quantity',
          hintText: '21,000,000',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: quantityController.text != '' &&
                  !quantityValidation(quantityController.text.toInt())
              ? 'must ${quantityController.text.toInt()} be between 1 and 21,000,000'
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

  Widget ipfsField() => TextField(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'IPFS/TX id',
          hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
          //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
          errorText: !ipfsValidation(ipfsController.text)
              ? '${MainCreate.ipfsLength - ipfsController.text.length}'
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
          onPressed: enabled
              ? () => submit()
              : () {
                  print(nameController.text.length > 2);
                  print(nameValidation(nameController.text));
                  print(ipfsController.text != '');
                  print(ipfsValidation(ipfsController.text));
                  print(quantityController.text != '');
                  print(quantityValidation(quantityController.text.toInt()));
                },
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
    var ret = true;
    if (!(name.length > 2 && name.length <= remainingNameLength)) {
      nameValidationErr = '${remainingNameLength - nameController.text.length}';
      ret = false;
    } else if (name.endsWith('.') || name.endsWith('_')) {
      nameValidationErr = 'cannot end with special character';
      ret = false;
    } else {
      nameValidationErr = null;
    }
    return ret;
  }

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated || !nameValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs.length <= MainCreate.ipfsLength;

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
      quantity <= MainCreate.quantityMax &&
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
      ipfsValidation(ipfsController.text) &&
      quantityController.text != '' &&
      quantityValidation(quantityController.text.toInt()) &&
      decimalController.text != '' &&
      decimalValidation(decimalController.text.toInt());

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// make the send request
      var createRequest = MainCreateRequest(
          name: nameController.text,
          ipfs: ipfsController.text,
          quantity: 0,
          decimals: 0,
          parent: 'PARENT/ASSET/PATH/#');

      /// send them to transaction checkout screen
      confirmSend(createRequest);
    }
  }

  void confirmSend(MainCreateRequest createRequest) {
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
            ['Quantity', quantityController.text],
            ['Decimals', quantityController.text],
            ['IPFS/Tx Id', ipfsController.text, '9'],
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
          buttonWord: 'Send',
        )
      },
    );
  }
}
