import 'assets.dart' as assets;
import 'transform.dart' as transform;
import 'strings.dart' as imported_strings;

export 'exceptions.dart';
export 'structures.dart';

class utils {
  static final assetHoldings = assets.assetHoldings;
  static final satToAmount = transform.satToAmount;
  static final amountToSat = transform.amountToSat;
  static final divisor = transform.divisor;
  //static final characters = transform.characters;
  static final removeChars = transform.removeChars;
  static final enumerate = transform.enumerate;
  static final removeCharsOtherThan = transform.removeCharsOtherThan;
  static final Strings strings = Strings();
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
