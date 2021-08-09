import 'package:hive/hive.dart';
import 'package:raven/records/security_type.dart';

part 'security.g.dart';

const Security RVN = Security(symbol: 'RVN', securityType: SecurityType.Crypto);
const Security USD = Security(symbol: 'USD', securityType: SecurityType.Fiat);

@HiveType(typeId: 8)
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
