import 'package:equatable/equatable.dart';
import 'package:magic/domain/concepts/coin.dart';
import 'package:magic/domain/concepts/fiat.dart';
import 'package:magic/domain/concepts/sats.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';

//final RelativeDateFormat _relativeDateFormatter = const RelativeDateFormat(
//      defaultRelativeDateLocalization as Locale,
//      localizations: [defaultRelativeDateLocalization]);
const RelativeDateLocalization defaultRelativeDateLocalization =
    RelativeDateLocalization(
  languageCode: 'en',
  timeUnitsSingular: [
    'second',
    'minute',
    'hour',
    'day',
    'week',
    'month',
    'year',
  ],
  timeUnitsPlural: [
    'seconds',
    'minutes',
    'hours',
    'days',
    'weeks',
    'months',
    'years',
  ],
  prepositionPast: 'ago',
  prepositionFuture: 'in',
  atTheMoment: 'now',
  formatOrderPast: [
    FormatComponent.value,
    FormatComponent.unit,
    FormatComponent.preposition
  ],
  formatOrderFuture: [
    FormatComponent.preposition,
    FormatComponent.value,
    FormatComponent.unit,
  ],
);

class TransactionDisplay extends Equatable {
  final bool incoming;
  final DateTime when;
  final Sats sats;

  const TransactionDisplay({
    required this.incoming,
    required this.when,
    required this.sats,
  });

  //const TransactionDisplay.empty()
  //    : incoming = true,
  //      when = const DateTime(0),
  //      sats = const Sat.empty();

  factory TransactionDisplay.empty() => TransactionDisplay(
        incoming: true,
        when: DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        sats: const Sats.empty(),
      );

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        incoming,
        when,
        sats,
      ];

  bool get isEmpty => sats.isEmpty;
  //String get humanWhen =>
  //    _relativeDateTime.toString(); // when.toIso8601String();
  //String humanWhen([RelativeDateFormat? relativeDateFormat]) =>
  //    (relativeDateFormat ?? _relativeDateFormatter).format(_relativeDateTime);
  String humanWhen(RelativeDateFormat relativeDateFormat) =>
      relativeDateFormat.format(_relativeDateTime);
  RelativeDateTime get _relativeDateTime =>
      RelativeDateTime(dateTime: DateTime.now(), other: when);

  Coin get coin => sats.toCoin;
  Fiat get fiat {
    // if we have a rate for this asset to USD then
    //we can convert and return
    //coin.toFiat(rate)
    //else
    return const Fiat.empty();
  }
}
