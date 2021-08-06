import 'package:raven/init/reservoirs.dart';
import 'package:raven/init/services.dart';
import 'package:raven/subjects/settings.dart';
import 'package:raven_electrum_client/raven_electrum_client.dart';

void init() {
  makeReservoirs();
  electrumSettingsStream(settings).listen(handleListening);
}

Stream electrumSettingsStream(settings) {
  return settings
      .map((s) =>
          [s['electrum.url'], s['electrum.port']]) // testnet.rvn.rocks:50002
      .distinct();
}

Future handleListening(element) async {
  var client = await generateClient(element[0], element[1]);
  deinitServices();
  initServices(client);
}

Future generateClient(String url, [int port = 50002]) async {
  return await RavenElectrumClient.connect(url, port: port);
}
