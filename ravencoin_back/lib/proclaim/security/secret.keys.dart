part of 'secret.dart';

class _IdKey extends Key<Secret> {
  @override
  String getKey(Secret secret) => secret.id;
}

extension ByIdMethodsForSecret on Index<_IdKey, Secret> {
  Secret? getOne(
    String? pubkey,
    String? scripthash,
    int? passwordId,
    SecretType secretType,
  ) =>
      getByKeyStr(Secret.primaryId(pubkey, scripthash, passwordId, secretType))
          .firstOrNull;
}

/// byLink

class _LinkKey extends Key<Secret> {
  @override
  String getKey(Secret secret) => secret.linkId.toString();
}

extension ByPasswordMethodsForSecret on Index<_LinkKey, Secret> {
  List<Secret> getOne(String? pubkey, String? scripthash, int? passwordId) =>
      getByKeyStr(Secret.LinkId(pubkey, scripthash, passwordId));
}

/// byPubkey

extension ByPubkeyMethodsForSecret on Index<_LinkKey, Secret> {
  Secret? getOne(String pubkey) =>
      getByKeyStr(Secret.LinkId(pubkey, null, null)).firstOrNull;
}

/// byScripthash

extension ByScripthashMethodsForSecret on Index<_LinkKey, Secret> {
  Secret? getOne(String scripthash) =>
      getByKeyStr(Secret.LinkId(null, scripthash, null)).firstOrNull;
}

/// byPasswordId

extension ByPasswordIdMethodsForSecret on Index<_LinkKey, Secret> {
  Secret? getOne(int passwordId) =>
      getByKeyStr(Secret.LinkId(null, null, passwordId)).firstOrNull;
}
