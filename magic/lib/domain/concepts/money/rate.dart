import 'package:equatable/equatable.dart';
import 'package:magic/domain/concepts/money/currency.dart';
import 'package:magic/domain/concepts/money/security.dart';

/// base/quote USD/RVN
class Rate with EquatableMixin {
  final Security base;
  final Currency quote;
  final double rate;

  const Rate({
    required this.base,
    this.quote = Currency.usd,
    required this.rate,
  });

  factory Rate.from(
    Rate given, {
    Security? base,
    Currency? quote,
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

  @override
  String toString() => '$base/$quote=$rate';
}
