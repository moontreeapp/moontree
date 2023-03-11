import 'package:client_back/records/records.dart';
import 'package:client_back/server/src/protocol/protocol.dart' show CommString;
import 'package:client_front/infrastructure/calls/broadcast.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

/// unused as broadcast is a one time thing that we don't save
class BroadcastTransactionRepo extends Repository<CommString> {
  final String rawTransactionHex;
  late Chain chain;
  late Net net;
  BroadcastTransactionRepo({
    required this.rawTransactionHex,
    Chain? chain,
    Net? net,
  }) : super(CommString(error: 'fallback value')) {
    this.chain = chain ?? Current.chain;
    this.net = net ?? Current.net;
  }

  @override
  Future<CommString> fromServer() async => BroadcastTransactionCall(
        chain: chain,
        net: net,
        rawTransactionHex: rawTransactionHex,
      )();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  CommString? fromLocal() => null;

  /// don't save or retrieve broadcast tx? why wold we need it?
  @override
  Future<void> save() async => null;
}
