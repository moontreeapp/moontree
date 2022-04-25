import '../../raven_electrum.dart';

extension PingServerMethod on RavenElectrumClient {
  Future<dynamic> ping() async => await request('server.ping');
}
