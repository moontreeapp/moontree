// ignore_for_file: avoid_classes_with_only_static_members, camel_case_types

import 'package:client_back/records/balance.dart';
import 'package:client_back/records/security.dart';
import 'package:client_back/records/transaction.dart';
import 'assets.dart' as assets;
import 'structures.dart';

export 'structures.dart';
export 'visibility.dart';

class utils {
  static const Set<Security> Function(Iterable<Transaction> transactions)
      securityFromTransactions = assets.securityFromTransactions;
  static const List<AssetHolding> Function(Iterable<Balance> holdings)
      assetHoldings = assets.assetHoldings;
  static const Map<String, AssetHolding> Function(String parent)
      assetHoldingsFromAssets = assets.assetHoldingsFromAssets;
}
