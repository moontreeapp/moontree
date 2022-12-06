// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'package:ravencoin_back/records/types/net.dart';
import 'package:ravencoin_back/records/transaction.dart';
import 'package:ravencoin_back/records/security.dart';
import 'package:ravencoin_back/records/balance.dart';
import 'assets.dart' as assets;
import 'strings.dart' as imported_strings;
import 'structures.dart';
import 'validate.dart' as validate;
import 'search.dart' as search;

export 'structures.dart';
export 'visibility.dart';

class utils {
  static const Set<Security> Function(Iterable<Transaction> transactions)
      securityFromTransactions = assets.securityFromTransactions;
  static const List<AssetHolding> Function(Iterable<Balance> holdings)
      assetHoldings = assets.assetHoldings;
  static const Map<String, AssetHolding> Function(String parent)
      assetHoldingsFromAssets = assets.assetHoldingsFromAssets;
  static const String Function(dynamic object, List items, List<String> names)
      toStringOverride = imported_strings.toStringOverride;
  static const int Function(
      {Comparator? comp,
      required List list,
      required dynamic value}) binarySearch = search.binarySearch;
  static const bool Function(
      {Comparator? comp,
      required List list,
      required dynamic value}) binaryRemove = search.binaryRemove;
  static const bool Function(
      {Comparator? comp,
      bool double_add,
      required List list,
      required dynamic value}) binaryInsert = search.binaryInsert;
  static final Strings strings = Strings();
  static final Validate validate = Validate();
}

class Validate {
  final bool Function(String x) isIpfs = validate.isIpfs;
  final bool Function(String x) isAddressRVN = validate.isAddressRVN;
  final bool Function(String x) isAddressRVNt = validate.isAddressRVNt;
  final bool Function(String x) isAddressEVR = validate.isAddressEVR;
  final bool Function(String x) isAddressEVRt = validate.isAddressEVRt;
  final bool Function(String x) isTxIdRVN = validate.isTxIdRVN;
  final bool Function(String x) isAdmin = validate.isAdmin;
  final bool Function(String x) isAssetPath = validate.isAssetPath;
  final bool Function(String x) isMainAsset = validate.isMainAsset;
  final bool Function(String x) isSubAsset = validate.isSubAsset;
  final bool Function(String x) isNFT = validate.isNFT;
  final bool Function(String x) isChannel = validate.isChannel;
  final bool Function(String x) isRestricted = validate.isRestricted;
  final bool Function(String x) isQualifier = validate.isQualifier;
  final bool Function(String x) isSubQualifier = validate.isSubQualifier;
  final bool Function(String x) isQualifierString = validate.isQualifierString;
  final bool Function(String x) isMemo = validate.isMemo;
  final bool Function(String x) isAssetData = validate.isAssetData;
  final bool Function(num x) isRVNAmount = validate.isRVNAmount;
}

class Strings {
  final String whiteSapce = imported_strings.whiteSapce;
  final String punctuationProblematic = imported_strings.punctuationProblematic;
  final String punctuationNonProblematic =
      imported_strings.punctuationNonProblematic;
  final String punctuation = imported_strings.punctuation;
  final String punctuationMinusCurrency =
      imported_strings.punctuationMinusCurrency;
  final String alphanumeric = imported_strings.alphanumeric;
  final String addressChars = imported_strings.addressChars;
  final String base58 = imported_strings.base58;
  final String base58Regex = imported_strings.base58Regex;
  final String Function(Net? net) ravenBase58Regex =
      imported_strings.ravenBase58Regex;
  final String assetBaseRegex = imported_strings.assetBaseRegex;
  final String subAssetBaseRegex = imported_strings.subAssetBaseRegex;
  final String mainAssetAllowed = imported_strings.mainAssetAllowed;
  final String verifierStringAllowed = imported_strings.verifierStringAllowed;
}

abstract class ToStringMixin {
  @override
  String toString() =>
      imported_strings.toStringOverride(this, props, propNames);
  List<Object?> get props => <Object?>[];
  List<String> get propNames => [];
}
