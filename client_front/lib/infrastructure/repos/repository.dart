enum RepoSource { local, server, electrumx }

class Repository<T> {
  T Function(String error) fallback;
  late RepoSource source;
  late T results;
  late Map<RepoSource, String> errors;
  Repository(this.fallback) {
    errors = <RepoSource, String>{};
  }

  bool resultsIsInitialized() {
    try {
      print("Results<$T>: $results");
      return true;
    } catch (e) {
      print("Results has not been initialized yet.");
      return false;
    }
  }

  String extractError(dynamic resultServer) => resultServer.error!;
  bool detectServerError(dynamic resultServer) => resultServer.error != null;
  bool detectLocalError(dynamic resultLocal) => resultLocal == null;

  /// fetches values from server; if that fails, from cache; saves results
  /// and any errors encountered to self. saves to cache automatically.
  Future<T> fetch({bool only = false}) async {
    Future<T?> handleError() async {
      print(errors);
      if (only) {
        results = fallback(errors[RepoSource.server]!);
        return results;
      }
      var resultLocal;
      if (fromLocal.runtimeType.toString().contains('Future<')) {
        resultLocal = await fromLocal();
      } else {
        resultLocal = fromLocal();
        print('resultLocal $resultLocal');
      }
      if (detectLocalError(resultLocal)) {
        errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      } else {
        source = RepoSource.local;
        results = resultLocal;
      }
      return null;
    }

    var resultServer;
    bool connErr = false;
    try {
      resultServer = await fromServer();
      print('resultServer $resultServer');
    } catch (e) {
      connErr = true;
    }
    if (connErr) {
      errors[RepoSource.server] = 'Connection Error';
      handleError();
    } else if (detectServerError(resultServer)) {
      errors[RepoSource.server] = extractError(resultServer);
      handleError();
    } else {
      source = RepoSource.server;
      results = resultServer;
      save();
    }
    if (resultsIsInitialized()) {
      return results;
    }
    // remake the client in the way that would work, and try again.
    return results;
  }

  /// gets values from cache; if that fails, from server; saves results
  /// and any errors encountered to self. saves to cache automatically.
  Future<T> get({bool only = false}) async {
    final resultLocal = fromLocal();
    if (detectLocalError(resultLocal)) {
      errors[RepoSource.local] = 'cache not implemented'; //'nothing cached'
      if (only) {
        results = fallback(errors[RepoSource.local]!);
        return results;
      }
      final resultServer = await fromServer();
      if (detectServerError(resultServer)) {
        errors[RepoSource.server] = extractError(resultServer);
        results = fallback(errors[RepoSource.server]!);
      } else {
        source = RepoSource.server;
        results = resultServer;
        await save();
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
