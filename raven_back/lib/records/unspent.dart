import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/raven_back.dart';

import '_type_id.dart';

part 'unspent.g.dart';

@HiveType(typeId: TypeId.Unspent)
class Unspent with EquatableMixin, ToStringMixin {
  @HiveField(0)
  String addressId;

  @HiveField(1)
  String transactionId;

  @HiveField(2)
  int position;

  @HiveField(3)
  int height;

  @HiveField(4)
  int value;

  @HiveField(5)
  String? symbol;

  @HiveField(6)
  String? memo;

  Unspent({
    required this.addressId,
    required this.transactionId,
    required this.position,
    required this.height,
    required this.value,
    this.symbol,
    this.memo,
  });

  @override
  List<Object?> get props => [
        addressId,
        transactionId,
        position,
        height,
        value,
        symbol,
        memo,
      ];

  @override
  bool? get stringify => true;

  @override
  List<String> get propNames => [
        'addressId',
        'transactionId',
        'position',
        'height',
        'value',
        'symbol',
        'memo',
      ];

  String get scripthash => addressId;
  String get txHash => transactionId;
  String get id => getUnspentId(transactionId, position);

  static String getUnspentId(String transactionId, int position) =>
      '$transactionId:$position';

  int securityValue({Security? security}) => security == null ||
          (security.symbol == res.securities.RVN.symbol &&
              security.securityType == SecurityType.Crypto)
      ? value
      : (security.symbol == symbol)
          ? value
          : 0;
}
