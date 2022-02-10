import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/theme/extensions.dart';
import 'package:raven_front/utils/transformers.dart';

class QualifierCreate extends StatefulWidget {
  static const int ipfsLength = 89;
  static const int quantityMax = 21000000;

  @override
  _QualifierCreateState createState() => _QualifierCreateState();
}

class _QualifierCreateState extends State<QualifierCreate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  FocusNode nameFocus = FocusNode();
  FocusNode quantityFocus = FocusNode();
  FocusNode ipfsFocus = FocusNode();
  FocusNode nextFocus = FocusNode();
  bool nameValidated = false;
  bool quantityValidated = false;
  bool ipfsValidated = false;
  String? nameValidationErr;
  // must get the exact number 30: #RVN/#25...
  int remainingNameLength = 25;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    nameController.dispose();
    ipfsController.dispose();
    quantityController.dispose();
    nameFocus.dispose();
    quantityFocus.dispose();
    ipfsFocus.dispose();
    nextFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: body(),
      );

  Widget body() => Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              nameField(),
              SizedBox(height: 16),
              quantityField(),
              SizedBox(height: 16),
              ipfsField(),
            ],
          ),
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

  Widget nameField() => TextField(
      focusNode: nameFocus,
      autocorrect: false,
      controller: nameController,
      textInputAction: TextInputAction.done,
      inputFormatters: [MainAssetNameTextFormatter()],
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'Qualifier Asset Name',
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
        FocusScope.of(context).requestFocus(ipfsFocus);
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
        onEditingComplete: () => FocusScope.of(context).requestFocus(ipfsFocus),
      );

  Widget ipfsField() => TextField(
        focusNode: ipfsFocus,
        autocorrect: false,
        controller: ipfsController,
        textInputAction: TextInputAction.done,
        decoration: components.styles.decorations.textFeild(
          context,
          labelText: 'IPFS/Txid',
          hintText: 'QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr',
          errorText: !ipfsValidation(ipfsController.text)
              ? '${QualifierCreate.ipfsLength - ipfsController.text.length}'
              : null,
        ),
        onChanged: (String value) => validateIPFS(ipfs: value),
        onEditingComplete: () => FocusScope.of(context).requestFocus(nextFocus),
      );

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

  bool quantityValidation(int quantity) =>
      quantityController.text != '' &&
      quantity <= QualifierCreate.quantityMax &&
      quantity > 0;

  void validateQuantity({int? quantity}) {
    quantity = quantity ?? quantityController.text.toInt();
    var oldValidation = quantityValidated;
    quantityValidated = quantityValidation(quantity);
    if (oldValidation != quantityValidated || !quantityValidated) {
      setState(() => {});
    }
  }

  bool ipfsValidation(String ipfs) => ipfs.length <= QualifierCreate.ipfsLength;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() => {});
    }
  }

  bool get enabled =>
      nameController.text.length > 2 &&
      nameValidation(nameController.text) &&
      quantityController.text != '' &&
      quantityValidation(quantityController.text.toInt()) &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// make the send request
      var createRequest = QualifierCreateRequest(
          name: nameController.text,
          ipfs: ipfsController.text,
          quantity: quantityController.text,
          parent: '#PARENT/#ASSET/#PATH/#');

      /// send them to transaction checkout screen
      confirmSend(createRequest);
    }
  }

  void confirmSend(QualifierCreateRequest createRequest) {
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
            ['Parent', '#PARENT/#ASSET/#PATH/#', '2'],
            ['Qualifier Asset Name', nameController.text, '2'],
            ['Quantity', quantityController.text, '2'],
            ['IPFS/Txid', ipfsController.text, '9'],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () => null,

          /// send the QualifierCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
          buttonWord: 'Send',
        )
      },
    );
  }
}
