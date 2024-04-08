import 'package:equatable/equatable.dart';
import 'package:magic/domain/concepts/sats.dart';

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
}
