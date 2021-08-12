import 'createMapSubject.dart';

var settings = createMapSubject(
  'settings',
  defaults: {
    'electrum.url': 'testnet.rvn.rocks',
    'electrum.port': 50002,
  },
);
