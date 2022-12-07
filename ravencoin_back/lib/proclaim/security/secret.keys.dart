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
      getByKeyStr(Secret.key(pubkey, scripthash, passwordId, secretType))
          .firstOrNull;
}

/// byLink

class _LinkKey extends Key<Secret> {
  @override
  String getKey(Secret secret) => secret.linkId;
}

extension ByPasswordMethodsForSecret on Index<_LinkKey, Secret> {
  List<Secret> getOne(String? pubkey, String? scripthash, int? passwordId) =>
      getByKeyStr(Secret.linkKey(pubkey, scripthash, passwordId));
  Secret? getOneByPubkey(String pubkey) =>
      getByKeyStr(Secret.linkKey(pubkey, null, null)).firstOrNull;
  Secret? getOneByScripthash(String scripthash) =>
      getByKeyStr(Secret.linkKey(null, scripthash, null)).firstOrNull;
  Secret? getOneByPasswordId(int passwordId) =>
      getByKeyStr(Secret.linkKey(null, null, passwordId)).firstOrNull;
}
