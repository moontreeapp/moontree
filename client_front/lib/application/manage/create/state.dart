part of 'cubit.dart';

@immutable
class SimpleCreateFormState extends CubitState {
  final SymbolType? type;
  final String parentName;
  final String name;
  final String memo;
  final int quantity;
  final int decimals;
  final bool reissuable;
  final List<UnsignedTransactionResult>? unsigned;
  final List<wutx.Transaction>? signed;
  final List<String>? txHash;
  final SimpleCreateCheckoutForm? checkout;
  final bool isSubmitting;

  const SimpleCreateFormState({
    required this.type,
    this.parentName = '',
    this.name = '',
    this.memo = '',
    this.quantity = 0,
    this.decimals = 0,
    this.reissuable = true,
    this.unsigned,
    this.signed,
    this.txHash,
    this.checkout,
    this.isSubmitting = false,
  });

  @override
  String toString() =>
      'SpendForm(type=$type, parentName=$parentName, quantity=$quantity, '
      'decimals=$decimals, reissuable=$reissuable '
      'unsigned=$unsigned, signed=$signed, txHash=$txHash, name=$name, '
      'checkout=$checkout, isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        parentName,
        name,
        memo,
        quantity,
        decimals,
        reissuable,
        unsigned,
        signed,
        txHash,
        checkout,
        isSubmitting,
      ];

  factory SimpleCreateFormState.initial() => SimpleCreateFormState(type: null);

  SimpleCreateFormState load({
    SymbolType? type,
    String? parentName,
    String? name,
    String? memo,
    int? quantity,
    int? decimals,
    bool? reissuable,
    List<UnsignedTransactionResult>? unsigned,
    List<wutx.Transaction>? signed,
    List<String>? txHash,
    SimpleCreateCheckoutForm? checkout,
    bool? isSubmitting,
  }) =>
      SimpleCreateFormState(
        type: type ?? this.type,
        parentName: parentName ?? this.parentName,
        name: name ?? this.name,
        quantity: quantity ?? this.quantity,
        memo: memo ?? this.memo,
        decimals: decimals ?? this.decimals,
        reissuable: reissuable ?? this.reissuable,
        unsigned: unsigned ?? this.unsigned,
        signed: signed ?? this.signed,
        txHash: txHash ?? this.txHash,
        checkout: checkout ?? this.checkout,
        isSubmitting: isSubmitting ?? this.isSubmitting,
      );
}

class SimpleCreateCheckoutForm with EquatableMixin {
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

  const SimpleCreateCheckoutForm({
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
    this.loadingMessage = 'Createing Transaction',
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
    <String>['long quantity', '21,000,000.00000000']
  ];

  bool get disabled => estimate!.fees == 0;

  SimpleCreateCheckoutForm newEstimate(SendEstimate sendEstimate) =>
      SimpleCreateCheckoutForm(
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
