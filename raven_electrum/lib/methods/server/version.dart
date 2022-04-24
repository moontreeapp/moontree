import '../../raven_electrum.dart';

class ServerVersion {
  String name;
  String protocol;
  ServerVersion(this.name, this.protocol);
}

extension ServerVersionMethod on RavenElectrumClient {
  Future<ServerVersion> serverVersion({
    String clientName = 'RavenElectrumClient',
    String protocolVersion = '1.9',
  }) async {
    var proc = 'server.version';
    var response = await request(proc, [clientName, protocolVersion]);
    return ServerVersion(response[0], response[1]);
  }
}
