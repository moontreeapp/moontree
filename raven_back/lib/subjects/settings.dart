/// should settings be a reservoir? we'll want to keep them and save them to disk just like all other data.
import 'createMapSubject.dart';

var settings = createMapSubject(
  'settings',
  defaults: {
    'electrum.url': 'testnet.rvn.rocks',
    'electrum.port': 50002,
  },
);
