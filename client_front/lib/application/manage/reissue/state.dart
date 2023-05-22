part of 'cubit.dart';

@immutable
class SimpleReissueFormCubitState extends Equatable {
  final SymbolType? type;
  final String parentName;
  final String name;
  final String memo;
  final String assetMemo;
  final String verifierString;
  final int quantity;
  final int decimals;
  final bool reissuable;
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
    this.memo = '',
    this.assetMemo = '',
    this.verifierString = '',
    this.quantity = 0,
    this.decimals = 0,
    this.reissuable = true,
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
      'quantity=$quantity, decimals=$decimals, reissuable=$reissuable, '
      'memo=$memo, assetMemo=$assetMemo, verifierString=$verifierString, '
      'unsigned=$unsigned, signed=$signed, txHash=$txHash, fee=$fee, '
      'changeAddress=$changeAddress, metadataView=$metadataView, '
      'isSubmitting=$isSubmitting)';

  @override
  List<Object?> get props => <Object?>[
        type,
        parentName,
        name,
        memo,
        assetMemo,
        verifierString,
        quantity,
        decimals,
        reissuable,
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

  int get assetCreationFeeSats => assetCreationFee * satsPerCoin;

  // in coins
  int get assetCreationFee {
    switch (type) {
      case SymbolType.main:
        return 500;
      case SymbolType.sub:
        return 100;
      case SymbolType.qualifier:
        return 1000;
      case SymbolType.qualifierSub:
        return 100;
      case SymbolType.restricted:
        return 1500;
      case SymbolType.channel:
        return 100;
      case SymbolType.unique:
        return 5;
      default:
        return 500;
    }
  }

  String get assetCreationName {
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
    super.memo,
    super.assetMemo,
    super.verifierString,
    super.decimals,
    super.reissuable,
    super.changeAddress,
    super.metadataView,
    super.unsigned,
    super.signed,
    super.txHash,
    super.fee,
    super.isSubmitting,
  });
}
