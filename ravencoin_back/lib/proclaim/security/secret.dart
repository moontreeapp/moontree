import 'package:quiver/iterables.dart';
import 'package:collection/collection.dart';
import 'package:proclaim/proclaim.dart';
import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:ravencoin_back/security/encrypted_wallet_secret.dart';

part 'secret.keys.dart';

class SecretProclaim extends Proclaim<_IdKey, Secret> {
  late IndexMultiple<_LinkKey, Secret> byLink;

  SecretProclaim() : super(_IdKey()) {
    byLink = addIndexMultiple('byLink', _LinkKey());
  }
  static Map<String, Secret> get defaults => <String, Secret>{};

  int? get maxPasswordId =>
      max(<int>[for (Secret secret in records) secret.passwordId!]);

  Secret? get currentPassword => records
      .where((Secret secret) => secret.passwordId == maxPasswordId)
      .firstOrNull;
}
