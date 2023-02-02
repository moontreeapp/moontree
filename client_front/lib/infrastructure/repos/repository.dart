enum RepoSource { local, server, electrumx }

class Repository<T> {
  T fallback;
  late RepoSource source;
  late T results;
  late Map<RepoSource, String> errors;
  Repository(this.fallback) {
    errors = <RepoSource, String>{};
  }

  String extractError(dynamic resultServer) => resultServer.error!;
  bool detectServerError(dynamic resultServer) => resultServer.error != null;
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  /// fetches values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  Future<T> fetch() async {
    final resultServer = await fromServer();
    if (detectServerError(resultServer)) {
      errors[RepoSource.server] = extractError(resultServer);
      final resultLocal = fromLocal();
      if (detectLocalError(resultLocal)) {
        errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
        results = fallback;
      } else {
        source = RepoSource.local;
        results = resultLocal;
      }
    } else {
      source = RepoSource.server;
      results = resultServer;
      save();
    }
    return results;
  }

  /// gets values from cache; if that fails, from server; saves results
  /// and any errors encountered to self. saves to cache automatically.
  Future<T> get() async {
    final resultLocal = fromLocal();
    if (detectLocalError(resultLocal)) {
      errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      final resultServer = await fromServer();
      if (detectServerError(resultServer)) {
        errors[RepoSource.server] = extractError(resultServer);
        results = fallback;
      } else {
        source = RepoSource.server;
        results = resultServer;
        save();
      }
    } else {
      source = RepoSource.local;
      results = resultLocal;
    }
    return results;
  }

  Future<dynamic> fromServer() async => null;

  /// server does not give null, local does because local null always indicates
  /// error (missing data), whereas empty might indicate empty data.
  dynamic fromLocal() => null;

  // todo: add results to correct cache.
  Future<void> save() async => null;
}
