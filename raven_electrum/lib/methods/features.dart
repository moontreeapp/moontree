import '../../raven_electrum_client.dart';

extension FeaturesMethod on RavenElectrumClient {
  Future<Map<String, dynamic>> features() async {
    var proc = 'server.features';
    return await request(proc);
  }
}
