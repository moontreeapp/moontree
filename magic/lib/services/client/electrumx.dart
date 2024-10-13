// ignore_for_file: omit_local_variable_types
import 'dart:async';
import 'dart:io';
import 'package:electrum_adapter/electrum_adapter.dart';
import 'package:magic/domain/blockchain/blockchain.dart';

/// client creation, logic, and settings.
class EClientService {
  RavenElectrumClient? electrumxClient;

  Future<RavenElectrumClient> get client async {
    var x = electrumxClient;
    if (x == null) {
      throw Exception('client not initialized');
      //await createClient();
    }
    return electrumxClient!;
  }

  Future<RavenElectrumClient?> createClient({
    Blockchain blockchain = Blockchain.evrmoreMain,
  }) async {
    final newRavenClient = await _generateClient(
      electrumDomain: blockchain.domain,
      electrumPort: blockchain.port,
    );
    if (newRavenClient != null) {
      electrumxClient = newRavenClient;
    }
    return null;
  }

  Future<RavenElectrumClient?> _generateClient({
    String projectName = 'Magic',
    String electrumDomain = 'moontree.com',
    int electrumPort = 50002,
  }) async {
    try {
      return await RavenElectrumClient.connect(
        electrumDomain,
        port: electrumPort,
        clientName: projectName,
        //clientVersion: 'v1.0',
        connectionTimeout: connectionTimeout,
      );
    } on SocketException catch (_) {
      print(_);
    }
    return null;
  }

  Future<List<ScripthashBalance>> getBalances(
    Iterable<String> scripthashes,
  ) async =>
      (await client).getBalances(scripthashes.toList());

  Future<List<List<ScripthashUnspent>>> getUnspents(
    Iterable<String> scripthashes,
  ) async =>
      (await client).getUnspents(scripthashes);

  Future<List<List<ScripthashUnspent>>> getAssetUnspents(
    Iterable<String> scripthashes,
  ) async =>
      (await client).getAssetUnspents(scripthashes);

  Future<List<ScripthashHistory>> getHistory(String scripthash) async =>
      (await client).getHistory(scripthash);

  Future<List<List<ScripthashHistory>>> getHistories(
    List<String> scripthashes,
  ) async =>
      (await client).getHistories(scripthashes);

  Future<Tx> getTransaction(String transactionId) async =>
      (await client).getTransaction(transactionId);

  Future<List<Tx>> getTransactions(Iterable<String> transactionIds) async =>
      (await client).getTransactions(transactionIds);

  Future<String> sendTransaction(String rawTx) async =>
      (await client).broadcastTransaction(rawTx);

  Future<AssetMeta?> getMeta(String symbol) async =>
      (await client).getMeta(symbol);
}
