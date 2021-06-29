import 'package:raven/electrum_client.dart';

import '../../electrum_client.dart';

extension FeaturesMethod on ElectrumClient {
  Future<Map<String, dynamic>> features() async {
    var proc = 'server.features';
    return await request(proc);
  }
}
