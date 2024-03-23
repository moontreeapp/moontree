// ignore_for_file: omit_local_variable_types

import 'dart:async';
import 'dart:io';
import 'package:client_back/records/address.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:electrum_adapter/electrum_adapter.dart';

/// client creation, logic, and settings.s
class EClientService {
  RavenElectrumClient? ravenElectrumClient;

  Future<RavenElectrumClient> get client async {
    var x = ravenElectrumClient;
    if (x == null) {
      throw Exception('client not initialized');
      //await createClient();
    }
    return ravenElectrumClient!;
  }

  Future<RavenElectrumClient?> createClient({
    Chain chain = Chain.ravencoin,
  }) async {
    final newRavenClient = await _generateClient(
      electrumDomain: chain.domain,
      electrumPort: chain.port,
    );
    print('newRavenClient: $newRavenClient');
    if (newRavenClient != null) {
      ravenElectrumClient = newRavenClient;
    }
    return null;
  }

  Future<RavenElectrumClient?> _generateClient({
    String projectName = 'moontree',
    String electrumDomain = 'moontree.com',
    int electrumPort = 50002,
  }) async {
    try {
      return await RavenElectrumClient.connect(
        electrumDomain,
        port: electrumPort,
        clientName: projectName,
        clientVersion: 'v1.0',
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
      (await client).getBalances(scripthashes);

  Future<List<List<ScripthashUnspent>>> getUnspents(
    Iterable<String> scripthashes,
  ) async =>
      (await client).getUnspents(scripthashes);

  Future<List<List<ScripthashUnspent>>> getAssetUnspents(
    Iterable<String> scripthashes,
  ) async =>
      (await client).getAssetUnspents(scripthashes);

  Future<List<ScripthashHistory>> getHistory(Address address) async =>
      (await client).getHistory(address.scripthash);

  Future<List<List<ScripthashHistory>>> getHistories(
    List<Address> addresses,
  ) async =>
      (await client).getHistories(addresses.map((Address a) => a.scripthash));

  Future<Tx> getTransaction(String transactionId) async =>
      (await client).getTransaction(transactionId);

  Future<List<Tx>> getTransactions(Iterable<String> transactionIds) async =>
      (await client).getTransactions(transactionIds);

  Future<String> sendTransaction(String rawTx) async =>
      (await client).broadcastTransaction(rawTx);

  Future<AssetMeta?> getMeta(String symbol) async =>
      (await client).getMeta(symbol);
}
