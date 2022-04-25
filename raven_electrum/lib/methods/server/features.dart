import '../../raven_electrum.dart';

extension FeaturesMethod on RavenElectrumClient {
  Future<Map<String, dynamic>> features() async =>
      await request('server.features');
}
