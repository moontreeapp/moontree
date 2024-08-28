part of 'cubit.dart';

class TransactionComponents {
  final int coinInput;
  final int fee;
  // assumes we're only sending to 1 address
  final bool targetAddressAmountVerified;
  // should be inputs - fee - target
  final bool changeAddressAmountVerified;
  const TransactionComponents({
    required this.coinInput,
    required this.fee,
    required this.targetAddressAmountVerified,
    required this.changeAddressAmountVerified,
  });

  bool get feeSanityCheck => fee < 2 * satsPerCoin;
}

class SendEstimate with ToStringMixin {
  SendEstimate({
    required this.amount,
    this.sendAll = false,
    this.fees = 0,
    this.security,
    this.assetMemo,
    this.memo,
    this.creation = false,
  });

  int amount; //sats
  bool sendAll;
  int fees;
  Security? security;
  Uint8List? assetMemo;
  String? memo;
  int extraFees = 0;
  bool creation;
  int coinReturn = 0;

  @override
  List<Object?> get props => <Object?>[
        amount,
        fees,
        security,
        assetMemo,
        memo,
        extraFees,
        creation,
      ];

  @override
  List<String> get propNames => <String>[
        'amount',
        'fees',
        'utxos',
        'security',
        'assetMemo',
        'memo',
        'extraFees',
        'creation',
      ];

  int get total => security == null || security!.isCoin
      ? sendAll
          ? (creation ? 0 : amount)
          : (creation ? 0 : amount) + fees + extraFees
      : fees + extraFees;

  void setFees(int fees_) => fees = fees_;
  void setCoinReturn(int coinReturn_) => coinReturn = coinReturn_;
  void setExtraFees(int fees_) => extraFees = fees_;
  void setCreation(bool creation_) => creation = creation_;
  void setAmount(int amount_) => amount = amount_;
}

class SendState with EquatableMixin, PriorActiveStateMixin {
  final bool active;
  final bool scanActive;
  final String asset; // TODO: use domain object
  final String address; // TODO: use domain object
  final String changeAddress; // TODO: use domain object
  final String amount; // TODO: use domain object
  final String originalAmount;
  final SendRequest? sendRequest; // TODO: use domain object
  //final UnsignedTransaction unsignedTransaction; // TODO: use domain object
  final UnsignedTransactionResultCalled?
      unsignedTransaction; // TODO: use domain object
  final List<Transaction> signedTransactions;
  final SendEstimate? estimate;
  final List<String> txHashes;
  final bool isSubmitting;
  final SendState? prior;

  const SendState({
    this.active = false,
    this.scanActive = false,
    this.asset = '',
    this.amount = '',
    this.originalAmount = '',
    this.address = '',
    this.changeAddress = '',
    this.sendRequest,
    this.unsignedTransaction,
    this.signedTransactions = const [],
    this.estimate,
    this.txHashes = const [],
    this.isSubmitting = false,
    this.prior,
  });

  @override
  List<Object?> get props => <Object?>[
        active,
        scanActive,
        asset,
        address,
        changeAddress,
        amount,
        originalAmount,
        sendRequest,
        unsignedTransaction,
        signedTransactions,
        estimate,
        txHashes,
        isSubmitting,
        prior,
      ];

  @override
  String toString() => '$runtimeType($props)';

  @override
  SendState get withoutPrior => SendState(
        active: active,
        scanActive: scanActive,
        asset: asset,
        address: address,
        changeAddress: changeAddress,
        amount: amount,
        originalAmount: originalAmount,
        sendRequest: sendRequest,
        unsignedTransaction: unsignedTransaction,
        signedTransactions: signedTransactions,
        estimate: estimate,
        txHashes: txHashes,
        isSubmitting: isSubmitting,
        prior: null,
      );

  @override
  bool get wasActive => prior?.active == true;

  @override
  bool get isActive => active;
}
