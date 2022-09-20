import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:proclaim/proclaim.dart';

part 'secret.keys.dart';

class SecretProclaim extends Proclaim<_IdKey, Secret> {
  late IndexMultiple<_LinkKey, Secret> byLink;
  late IndexMultiple<_LinkKey, Secret> byPubkey;
  late IndexMultiple<_LinkKey, Secret> byScripthash;

  SecretProclaim() : super(_IdKey()) {
    byLink = addIndexMultiple('byLink', _LinkKey());
    byPubkey = addIndexMultiple('byPubkey', _LinkKey());
    byScripthash = addIndexMultiple('byScripthash', _LinkKey());
  }
  static Map<String, Secret> get defaults => {};
}
