import 'package:hive/hive.dart';
import 'package:raven/records/security_type.dart';

import '_type_id.dart';

part 'security.g.dart';

const Security RVN = Security(symbol: 'RVN', securityType: SecurityType.Crypto);
const Security USD = Security(symbol: 'USD', securityType: SecurityType.Fiat);

@HiveType(typeId: TypeId.Security)
class Security {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final SecurityType securityType;

  const Security({
    required this.symbol,
    required this.securityType,
  });
}
