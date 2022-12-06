import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/security.dart';

import '_type_id.dart';

part 'rate.g.dart';

@HiveType(typeId: TypeId.Rate)
class Rate with EquatableMixin {
  @HiveField(0)
  Security base;

  @HiveField(1)
  Security quote;

  @HiveField(2)
  double rate;

  Rate({
    required this.base,
    required this.quote,
    required this.rate,
  });

  factory Rate.from(
    Rate given, {
    Security? base,
    Security? quote,
    double? rate,
  }) {
    return Rate(
      base: base ?? given.base,
      quote: quote ?? given.quote,
      rate: rate ?? given.rate,
    );
  }

  @override
  List<Object?> get props => <Object?>[base, quote, rate];

  String get id => Rate.rateKey(base, quote);

  static String rateKey(Security base, Security quote) =>
      '${base.id}:${quote.id}';
}
