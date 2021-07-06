A Dart-based client for Ravencoin ElectrumX servers

## Notes

The Ravencoin ElectrumX server is quite similar to the Bitcion Electrum server, but has additional methods that allow clients to handle asset issuance and transferral.

## Usage

```dart
import 'package:raven_electrum_client/raven_electrum_client.dart';

void main() async {
  var client =
      await RavenElectrumClient.connect('testnet.rvn.rocks', port: 50002);
  var features = await client.features();
  print(features);
  await client.close();
}
```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/moontreeapp/raven_electrum_client/issues
