part of 'cubit.dart';

@immutable
class SimpleReissueFormCubitState extends Equatable {
  final SymbolType? type;
  final String parentName;
  final String name;
  final int quantity; // sats
  final String quantityCoinString; // coin
  final int decimals;
  final bool reissuable;
  final String? memo;
  final String? assetMemo;
  final String? verifierString;
  final String changeAddress;
  final AssetMetadataResponse? metadataView;
  final UnsignedTransactionResult? unsigned;
  final List<wutx.Transaction>? signed;
  final List<String>? txHash;
  final int? fee;
  final bool isSubmitting;

  const SimpleReissueFormCubitState({
    required this.type,
    this.parentName = '',
    this.name = '',
    this.quantity = 0,
    this.quantityCoinString = '',
    this.decimals = 0,
    this.reissuable = true,
    this.memo,
    this.assetMemo,
    this.verifierString,
    this.changeAddress = '',
    this.metadataView,
    this.unsigned,
    this.signed,
    this.txHash,
    this.fee,
    this.isSubmitting = false,
  });

  @override
  String toString() =>
      'SpendForm(type=$type, parentName=$parentName, name=$name, '
      'quantity=$quantity, quantityCoinString=$quantityCoinString, '
      'decimals=$decimals, reissuable=$reissuable, '
      'memo=$memo, assetMemo=$assetMemo, verifierString=$verifierString, '
      'unsigned=$unsigned, signed=$signed, txHash=$txHash, fee=$fee, '
      'changeAddress=$changeAddress, metadataView=$metadataView, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        type,
        parentName,
        name,
        quantity,
        quantityCoinString,
        decimals,
        reissuable,
        memo,
        assetMemo,
        verifierString,
        changeAddress,
        metadataView,
        unsigned,
        signed,
        txHash,
        fee,
        isSubmitting,
      ];

  FeeRate? get feeRate => standardFee;

  double get quantityCoin => quantity.asCoin;

  int get assetReissueFeeSats => assetReissueFee * satsPerCoin;

  // in coins
  int get assetReissueFee => 100;

  String get assetReissueName {
    switch (type) {
      case SymbolType.main:
        return 'Main Asset';
      case SymbolType.sub:
        return 'Sub Asset';
      case SymbolType.qualifier:
        return 'Qualifier Asset';
      case SymbolType.qualifierSub:
        return 'Qualifier Sub Asset';
      case SymbolType.restricted:
        return 'Restricted Asset';
      case SymbolType.channel:
        return 'Channel Asset';
      case SymbolType.unique:
        return 'NFT';
      default:
        return 'Asset';
    }
  }

  String get fullname => getFullname(parentName: parentName, name: name);

  String getFullname({required String parentName, required String name}) {
    if (type == SymbolType.main) {
      return name;
    }
    if (type == SymbolType.restricted) {
      return (r'$' + name);
    } else if (type == SymbolType.qualifier) {
      return (r'#' + name);
    } else if (type == SymbolType.qualifierSub) {
      return (parentName + '#' + name);
    } else if (type == SymbolType.sub) {
      return (parentName + '/' + name);
    } else if (type == SymbolType.unique) {
      return (parentName + '#' + name);
    } else if (type == SymbolType.channel) {
      return (parentName + '~' + name);
    } else {
      return name;
    }
  }
}

class SimpleReissueFormState extends SimpleReissueFormCubitState {
  SimpleReissueFormState({
    super.type = null,
    super.parentName,
    super.name,
    super.quantity,
    super.quantityCoinString,
    super.decimals,
    super.reissuable,
    super.memo,
    super.assetMemo,
    super.verifierString,
    super.changeAddress,
    super.metadataView,
    super.unsigned,
    super.signed,
    super.txHash,
    super.fee,
    super.isSubmitting,
  });
}
