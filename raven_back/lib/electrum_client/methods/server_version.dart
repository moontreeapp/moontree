import '../../electrum_client.dart';

class ServerVersion {
  String name;
  String protocol;
  ServerVersion(this.name, this.protocol);
}

extension ServerVersionMethod on ElectrumClient {
  Future<ServerVersion> serverVersion(
      {clientName = 'MTWallet', protocolVersion = '1.8'}) async {
    var proc = 'server.version';
    var response = await request(proc, [clientName, protocolVersion]);
    return ServerVersion(response[0], response[1]);
  }
}
