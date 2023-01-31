enum RepoSource { local, server, electrumx }

class Repository {
  late RepoSource source;
  late Map<RepoSource, String> errors;
  Repository();

  Future<dynamic> get() async => null;

  Future<dynamic> fromServer() async => null;

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  dynamic fromLocal() => null;

  // todo: add results to correct cache.
  Future<void> save() async => null;
}
