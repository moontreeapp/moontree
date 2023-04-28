import 'package:client_back/client_back.dart';
import 'package:client_back/server/src/protocol/comm_int.dart';
import 'package:client_front/infrastructure/cache/ciruclating_sats.dart';
import 'package:client_front/infrastructure/calls/circulating_sats.dart';
import 'package:client_front/infrastructure/repos/repository.dart';
import 'package:client_front/infrastructure/services/lookup.dart';

class CirculatingSatsRepo extends Repository<CommInt> {
  late Chain chain;
  late Net net;

  CirculatingSatsRepo({
    Security? security,
    Chain? chain,
    Net? net,
  }) : super(generateFallback) {
    this.chain = chain ?? security?.chain ?? Current.chain;
    this.net = net ?? security?.net ?? Current.net;
  }
  static CommInt generateFallback([String? error]) =>
      CommInt(value: -1, error: 'error');

  @override
  bool detectServerError(dynamic resultServer) => resultServer.error != null;

  @override
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  @override
  String extractError(dynamic resultServer) => resultServer.error!;

  @override
  Future<CommInt> fromServer() async =>
      CirculatingSatsCall(chain: chain, net: net)();

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  @override
  CommInt? fromLocal() => CirculatingSatsCache.get(chain: chain, net: net);

  @override
  Future<void> save() async => CirculatingSatsCache.put(
        chain: chain,
        net: net,
        records: [results],
      );
}
