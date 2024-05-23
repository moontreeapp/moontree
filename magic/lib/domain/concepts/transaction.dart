import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:magic/domain/blockchain/blockchain.dart';
import 'package:magic/domain/concepts/numbers/coin.dart';
import 'package:magic/domain/concepts/numbers/fiat.dart';
import 'package:magic/domain/concepts/numbers/sats.dart';
import 'package:lit_relative_date_time/lit_relative_date_time.dart';
import 'package:magic/domain/server/protocol/protocol.dart';

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
  final Fiat? worth;
  final TransactionView? transactionView;
  final Blockchain? blockchain;

  const TransactionDisplay({
    required this.incoming,
    required this.when,
    required this.sats,
    this.worth,
    this.transactionView,
    this.blockchain,
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

  factory TransactionDisplay.fromTransactionView({
    required TransactionView transactionView,
    required Blockchain blockchain,
  }) =>
      TransactionDisplay(
        incoming: transactionView.iProvided == 0,
        when: transactionView.datetime,
        sats: Sats(transactionView.iProvided == 0
            ? transactionView.iReceived
            : transactionView.iProvided - transactionView.iReceived),
        transactionView: transactionView,
        blockchain: blockchain,
      );

  TransactionDisplay copyWith({
    bool? incoming,
    DateTime? when,
    Sats? sats,
    Fiat? worth,
  }) =>
      TransactionDisplay(
          incoming: incoming ?? this.incoming,
          when: when ?? this.when,
          sats: sats ?? this.sats,
          worth: worth ?? this.worth);

  @override
  String toString() => '$runtimeType($props)';

  @override
  List<Object?> get props => <Object?>[
        incoming,
        when,
        sats,
        worth,
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

  /// when we get dates from the server we should make sure we interpret them
  /// as UTC datetimes:
  /// // Simulate receiving a UTC date-time string
  /// String utcDateString = "2024-04-15T12:30:00Z";
  /// // Parsing the UTC string to a DateTime object
  /// DateTime utcDateTime = DateTime.parse(utcDateString).toUtc();

  String humanDate() =>
      DateFormat('MMMM d, yyyy', 'en_US').format(when.toLocal());
  String humanTime() => DateFormat('h:mm a').format(when.toLocal());

  Coin get coin => sats.toCoin();
  Fiat fiat(double? rate) {
    if (rate != null) {
      return coin.toFiat(rate);
    }
    return const Fiat.empty();
  }
}
