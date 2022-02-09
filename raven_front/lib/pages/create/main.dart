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

class MainCreate extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  @override
  _MainCreateState createState() => _MainCreateState();
}

class _MainCreateState extends State<MainCreate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController decimalController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode decimalFocus = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  bool quantityValidated = false;
  bool decimalValidated = false;
  // if this is a sub asset...
  // we will have to get this depending on which asset/subasset/ we're using to
  // make the main, but the most it could possibly be is 27 because main asset
  // name is at least 3 characters plus / and the most is 31: RVN/27...
  int remainingNameLength = 31; //sub asset max length: 27;

  @override
  void initState() {
    super.initState();
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

  Widget body() {
    var nameField = TextField(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'NFT Name',
        hintText: 'NFT Name',
        //helperText: nameValidation(nameController.text) ? 'something' : null,
        errorText: !nameValidation(nameController.text)
            ? '${remainingNameLength - nameController.text.length}'
            : null,
      ),
      onChanged: (String value) => validateName(name: value),
      onEditingComplete: () => FocusScope.of(context).requestFocus(ipfsFocus),
    );
    var ipfsField = TextField(
      focusNode: ipfsFocus,
      autocorrect: false,
      controller: ipfsController,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'IPFS/TX id',
        hintText: 'IPFS/TX id',
        //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
        errorText: !ipfsValidation(ipfsController.text)
            ? '${MainCreate.ipfsLength - ipfsController.text.length}'
            : null,
      ),
      onChanged: (String value) => validateIPFS(ipfs: value),
      onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
    );

    var quantityField = TextField(
      focusNode: quantityFocus,
      controller: quantityController,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly
      ], // Only numbers can be entered
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Quantity',
        hintText: 'Quantity',
        //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
        errorText: quantityController.text != '' &&
                !quantityValidation(quantityController.text.toInt())
            ? 'must be between 1 and 21,000,000'
            : null,
      ),
      onChanged: (String value) => validateQuantity(quantity: value.toInt()),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(decimalFocus),
    );

    return Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  nameField,
                  SizedBox(height: 16),
                  quantityField,
                  SizedBox(height: 16),
                  //decimalField,
                  SizedBox(height: 16),
                  ipfsField,
                  SizedBox(height: 16),
                  //reissueableField,
                  SizedBox(height: 16),
                ]),
            Padding(
                padding: EdgeInsets.only(
                  top: 0,
                  bottom: 40,
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [submitButton()]))
          ],
        ));
  }

  Widget submitButton() {
    return Container(
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
  }

  bool nameValidation(String name) => name.length <= remainingNameLength;

  void validateName({String? name}) {
    name = name ?? nameController.text;
    var oldValidation = nameValidated;
    nameValidated = nameValidation(name);
    if (oldValidation != nameValidated) {
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

  bool get enabled =>
      nameController.text.length > 2 &&
      nameValidation(nameController.text) &&
      ipfsController.text != '' &&
      ipfsValidation(ipfsController.text) &&
      quantityController.text != '' &&
      quantityValidation(quantityController.text.toInt());

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
          /// get the name we're creating the NFT under
          //symbol: ((streams.spend.form.value?.symbol == 'Ravencoin'
          //        ? 'RVN'
          //        : streams.spend.form.value?.symbol) ??
          //    'RVN'),
          subSymbol: '',
          paymentSymbol: 'RVN',
          items: [
            /// send the correct items
            ['Parent', 'PARENT/ASSET/PATH/#', '2'],
            ['NFT Name', nameController.text, '2'],
            ['Quantity', quantityController.text],
            ['Decimals', quantityController.text],
            ['IPFS/Tx Id', ipfsController.text, '9'],
            ['Reissuable', quantityController.text],
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
