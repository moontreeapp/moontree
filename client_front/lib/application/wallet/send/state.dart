part of 'cubit.dart';

@immutable
class SimpleSendFormState extends CubitState {
  final AssetMetadataResponse? metadataView;
  final Security security;
  final String address;
  final String changeAddress;
  final String amountStr;
  final double amount;
  final FeeRate fee;
  final String memo;
  final String note;
  final String addressName;
  final List<UnsignedTransactionResult>? unsigned;
  final List<wutx.Transaction>? signed;
  final List<String>? txHash;
  final SimpleSendCheckoutForm? checkout;
  final bool isSubmitting;

  const SimpleSendFormState({
    required this.metadataView,
    required this.security,
    this.address = '',
    this.changeAddress = '',
    this.amountStr = '',
    this.amount = 0.0,
    this.fee = standardFee,
    this.memo = '',
    this.note = '',
    this.addressName = '',
    this.unsigned,
    this.signed,
    this.txHash,
    this.checkout,
    this.isSubmitting = false,
  });

  @override
  String toString() =>
      'SpendForm(security=$security, address=$address, amount=$amount, '
      'amountStr=$amountStr, fee=$fee, note=$note, addressName=$addressName, '
      'unsigned=$unsigned, signed=$signed, txHash=$txHash, '
      'changeAddress=$changeAddress, checkout=$checkout, '
      'metadataView=$metadataView, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        metadataView,
        security,
        address,
        amountStr,
        amount,
        fee,
        memo,
        note,
        changeAddress,
        addressName,
        unsigned,
        signed,
        txHash,
        checkout,
        isSubmitting,
      ];

  factory SimpleSendFormState.initial() => SimpleSendFormState(
      metadataView: null, security: pros.securities.currentCoin);

  SimpleSendFormState load({
    AssetMetadataResponse? metadataView,
    Security? security,
    String? address,
    String? amountStr,
    double? amount,
    FeeRate? fee,
    String? memo,
    String? note,
    String? changeAddress,
    String? addressName,
    List<UnsignedTransactionResult>? unsigned,
    List<wutx.Transaction>? signed,
    List<String>? txHash,
    SimpleSendCheckoutForm? checkout,
    bool? isSubmitting,
  }) =>
      SimpleSendFormState(
        metadataView: metadataView ?? this.metadataView,
        security: security ?? this.security,
        address: address ?? this.address,
        amountStr: amountStr ?? this.amountStr,
        amount: amount ?? this.amount,
        fee: fee ?? this.fee,
        memo: memo ?? this.memo,
        note: note ?? this.note,
        changeAddress: changeAddress ?? this.changeAddress,
        addressName: addressName ?? this.addressName,
        unsigned: unsigned ?? this.unsigned,
        signed: signed ?? this.signed,
        txHash: txHash ?? this.txHash,
        checkout: checkout ?? this.checkout,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );

  String get fiatRepresentation {
    try {
      return services.conversion.securityAsReadable(
        sats,
        symbol: security.symbol,
        asUSD: true,
      );
    } catch (e) {
      return '';
    }
  }

  int get sats => (amount * satsPerCoin).round(); //amount.asSats;
}

class SimpleSendCheckoutForm with EquatableMixin {
  final Widget? icon;
  final String? symbol;
  final String displaySymbol;
  final String? subSymbol;
  final String? paymentSymbol;
  final double? left;
  final Iterable<Iterable<String>> items;
  final Iterable<Iterable<String>>? fees;
  final String? total;
  final String? confirm;
  final Function? buttonAction;
  final String? buttonWord;
  final Widget? button;
  final String loadingMessage;
  final int? playcount;
  final SendEstimate? estimate;

  const SimpleSendCheckoutForm({
    this.icon,
    this.left,
    this.symbol = '#MoonTree',
    this.displaySymbol = 'MoonTree',
    this.subSymbol = 'Main/',
    this.paymentSymbol = 'RVN',
    this.items = exampleItems,
    this.fees = exampleFees,
    this.total = '101',
    this.buttonAction,
    this.buttonWord = 'Submit',
    this.loadingMessage = 'Sending Transaction',
    this.confirm,
    this.button,
    this.playcount = 2,
    this.estimate,
  });

  @override
  List<Object?> get props => <Object?>[
        icon,
        symbol,
        displaySymbol,
        subSymbol,
        paymentSymbol,
        left,
        items,
        fees,
        total,
        confirm,
        buttonAction,
        buttonWord,
        button,
        loadingMessage,
        playcount,
        estimate,
      ];

  static const Iterable<Iterable<String>> exampleItems = <List<String>>[
    <String>['Short Text', 'aligned right'],
    <String>['Too Long Text (~20+ chars)', 'QmXwHQ43NrZPq123456789'],
    <String>[
      'Multiline (2) - Limited',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '2'
    ],
    <String>[
      'Multiline (5)',
      '(#KYC && #COOLDUDE) || (#OVERRIDE || #MOONTREE) && (!! #IRS)',
      '5'
    ]
  ];
  static const Iterable<Iterable<String>> exampleFees = <List<String>>[
    <String>['Transaction', '1'],
    <String>['Sub Asset', '100'],
    <String>['long amount', '21,000,000.00000000']
  ];

  bool get disabled => estimate!.fees == 0;

  SimpleSendCheckoutForm newEstimate(SendEstimate sendEstimate) =>
      SimpleSendCheckoutForm(
        icon: this.icon,
        symbol: this.symbol,
        displaySymbol: this.displaySymbol,
        subSymbol: this.subSymbol,
        paymentSymbol: this.paymentSymbol,
        left: this.left,
        items: this.items,
        fees: this.fees,
        total: this.total,
        confirm: this.confirm,
        buttonAction: this.buttonAction,
        buttonWord: this.buttonWord,
        button: this.button,
        loadingMessage: this.loadingMessage,
        playcount: this.playcount,
        estimate: sendEstimate,
      );
}
