import 'package:quiver/iterables.dart';

import 'package:collection/collection.dart';
import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/security/encrypted_wallet_secret.dart';

part 'secret.keys.dart';

class SecretProclaim extends Proclaim<_IdKey, Secret> {
  late IndexMultiple<_LinkKey, Secret> byLink;
  late IndexMultiple<_LinkKey, Secret> byPubkey;
  late IndexMultiple<_LinkKey, Secret> byScripthash;
  late IndexMultiple<_LinkKey, Secret> byPasswordId;

  SecretProclaim() : super(_IdKey()) {
    byLink = addIndexMultiple('byLink', _LinkKey());
    byPubkey = addIndexMultiple('byPubkey', _LinkKey());
    byScripthash = addIndexMultiple('byScripthash', _LinkKey());
    byPasswordId = addIndexMultiple('byPasswordId', _LinkKey());
  }
  static Map<String, Secret> get defaults => {};

  int? get maxPasswordId =>
      max([for (var secret in records) secret.passwordId!]);

  Secret? get currentPassword =>
      records.where((secret) => secret.passwordId == maxPasswordId).firstOrNull;
}
