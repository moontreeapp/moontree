import 'package:raven_electrum_client/raven_electrum_client.dart';

void main() async {
  var client =
      await RavenElectrumClient.connect('testnet.rvn.rocks', port: 50002);
  var features = await client.features();
  print(features);
  await client.close();
}
