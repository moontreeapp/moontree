part of 'secret.dart';

class _IdKey extends Key<Secret> {
  @override
  String getKey(Secret secret) => secret.id;
}

extension ByIdMethodsForSecret on Index<_IdKey, Secret> {
  Secret? getOne(String? pubkey, String? scripthash, String secret) =>
      getByKeyStr(Secret.primaryId(pubkey, scripthash, secret)).firstOrNull;
}

/// byLink

class _LinkKey extends Key<Secret> {
  @override
  String getKey(Secret secret) => secret.linkId.toString();
}

extension ByPasswordMethodsForSecret on Index<_LinkKey, Secret> {
  List<Secret> getOne(String? pubkey, String? scripthash) =>
      getByKeyStr(Secret.LinkId(pubkey, scripthash));
}

/// byPubkey

extension ByPubkeyMethodsForSecret on Index<_LinkKey, Secret> {
  Secret? getOne(String pubkey) =>
      getByKeyStr(Secret.LinkId(pubkey, null)).firstOrNull;
}

/// byScripthash

extension ByScripthashMethodsForSecret on Index<_LinkKey, Secret> {
  Secret? getOne(String scripthash) =>
      getByKeyStr(Secret.LinkId(null, scripthash)).firstOrNull;
}
