import 'assets.dart' as assets;
import 'transform.dart' as transform;
import 'strings.dart' as imported_strings;
import 'validate.dart' as validate;

export 'exceptions.dart';
export 'structures.dart';

class utils {
  static final assetHoldings = assets.assetHoldings;
  static final assetHoldingsFromAssets = assets.assetHoldingsFromAssets;
  static final satToAmount = transform.satToAmount;
  static final amountToSat = transform.amountToSat;
  //static final characters = transform.characters;
  static final removeChars = transform.removeChars;
  static final enumerate = transform.enumerate;
  static final removeCharsOtherThan = transform.removeCharsOtherThan;
  static final toStringOverride = imported_strings.toStringOverride;
  static final Strings strings = Strings();
  static final Validate validate = Validate();
}

class Validate {
  final isIpfs = validate.isIpfs;
  final isAddressRVN = validate.isAddressRVN;
  final isAddressRVNt = validate.isAddressRVNt;
  final isTxIdRVN = validate.isTxIdRVN;
  final isTxIdFlow = validate.isTxIdFlow;
  final isAdmin = validate.isAdmin;
  final isAssetPath = validate.isAssetPath;
  final isMainAsset = validate.isMainAsset;
  final isSubAsset = validate.isSubAsset;
  final isNFT = validate.isNFT;
  final isChannel = validate.isChannel;
  final isRestricted = validate.isRestricted;
  final isQualifier = validate.isQualifier;
  final isSubQualifier = validate.isSubQualifier;
  final isQualifierString = validate.isQualifierString;
  final isMemo = validate.isMemo;
  final isAssetMemo = validate.isAssetMemo;
  final isRVNAmount = validate.isRVNAmount;
}

class Strings {
  final whiteSapce = imported_strings.whiteSapce;
  final punctuationProblematic = imported_strings.punctuationProblematic;
  final punctuationNonProblematic = imported_strings.punctuationNonProblematic;
  final punctuation = imported_strings.punctuation;
  final punctuationMinusCurrency = imported_strings.punctuationMinusCurrency;
  final alphanumeric = imported_strings.alphanumeric;
  final addressChars = imported_strings.addressChars;
  final base58 = imported_strings.base58;
  final base58Regex = imported_strings.base58Regex;
  final ravenBase58Regex = imported_strings.ravenBase58Regex;
  final assetBaseRegex = imported_strings.assetBaseRegex;
  final subAssetBaseRegex = imported_strings.subAssetBaseRegex;
  final mainAssetAllowed = imported_strings.mainAssetAllowed;
  final verifierStringAllowed = imported_strings.verifierStringAllowed;
}

abstract class ToStringMixin {
  @override
  String toString() =>
      imported_strings.toStringOverride(this, props, propNames);
  List<Object?> get props => [];
  List<String> get propNames => [];
}
