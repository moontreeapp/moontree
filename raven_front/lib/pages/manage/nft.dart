import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/services/transaction_maker.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/transaction/checkout.dart';
import 'package:raven_front/theme/extensions.dart';

class NFTCreate extends StatefulWidget {
  static const int ipfsLength = 89;

  @override
  _NFTCreateState createState() => _NFTCreateState();
}

class _NFTCreateState extends State<NFTCreate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ipfsController = TextEditingController();
  FocusNode nameFocusNode = FocusNode();
  FocusNode ipfsFocusNode = FocusNode();
  FocusNode nextFocusNode = FocusNode();
  bool nameValidated = false;
  bool ipfsValidated = false;
  // we will have to get this depending on which asset/subasset/ we're using to
  // make the nft, but the most it could possibly be is 27 because main asset
  // name is at least 3 characters plus /# and the most is 31: RVN/#26...
  int remainingNameLength = 26;

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
    var newPasswordField = TextField(
      focusNode: nameFocusNode,
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
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(ipfsFocusNode),
    );
    var confirmPasswordField = TextField(
      focusNode: ipfsFocusNode,
      autocorrect: false,
      controller: ipfsController,
      textInputAction: TextInputAction.done,
      decoration: components.styles.decorations.textFeild(
        context,
        labelText: 'IPFS/TX id',
        hintText: 'IPFS/TX id',
        //helperText: ipfsValidation(ipfsController.text) ? 'match' : null,
        errorText: !ipfsValidation(ipfsController.text)
            ? '${NFTCreate.ipfsLength - ipfsController.text.length}'
            : null,
      ),
      onChanged: (String value) => validateIPFS(ipfs: value),
      onEditingComplete: () =>
          FocusScope.of(context).requestFocus(nextFocusNode),
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
                  newPasswordField,
                  SizedBox(height: 16),
                  confirmPasswordField
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
            focusNode: nextFocusNode,
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

  bool ipfsValidation(String ipfs) => ipfs.length <= NFTCreate.ipfsLength;

  void validateIPFS({String? ipfs}) {
    ipfs = ipfs ?? ipfsController.text;
    var oldValidation = ipfsValidated;
    ipfsValidated = ipfsValidation(ipfs);
    if (oldValidation != ipfsValidated || !ipfsValidated) {
      setState(() => {});
    }
  }

  bool get enabled =>
      nameController.text != '' &&
      nameValidation(nameController.text) &&
      ipfsController.text != '' &&
      ipfsValidation(ipfsController.text);

  void submit() {
    if (enabled) {
      FocusScope.of(context).unfocus();

      /// make the send request
      var createRequest = NFTCreateRequest(
          name: nameController.text,
          ipfs: ipfsController.text,
          parent: 'PARENT/ASSET/PATH/#');

      /// send them to transaction checkout screen
      confirmSend(createRequest);
    }
  }

  void confirmSend(NFTCreateRequest createRequest) {
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
            ['IPFS/Tx Id', ipfsController.text, '9'],
          ],
          fees: [
            ['Transaction Fee', 'calculating fee...']
          ],
          total: 'calculating total...',
          buttonAction: () => null,

          /// send the NFTCreate request to the right stream
          //streams.spend.send.add(streams.spend.made.value),
          buttonIcon: MdiIcons.arrowTopRightThick,
          buttonWord: 'Send',
        )
      },
    );
  }
}
