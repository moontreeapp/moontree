import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/security.dart';

import '_type_id.dart';

part 'rate.g.dart';

@HiveType(typeId: TypeId.Rate)
class Rate with EquatableMixin {
  @HiveField(0)
  final Security base;

  @HiveField(1)
  final Security quote;

  @HiveField(2)
  final double rate;

  const Rate({
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
