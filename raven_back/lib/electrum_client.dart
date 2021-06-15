import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:bitcoin_flutter/bitcoin_flutter.dart';
// import 'package:cake_wallet/bitcoin/bitcoin_amount_format.dart';
// import 'package:cake_wallet/bitcoin/script_hash.dart';
// import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

String jsonrpcparams(List<Object> params) {
  final _params = params.map((val) => '"${val.toString()}"').join(',');
  return '[$_params]';
}

String jsonrpc(
        {required String method,
        required List<Object> params,
        required int id,
        String version = '2.0'}) =>
    '{"jsonrpc": "$version", "method": "$method", "id": "$id",  "params": ${json.encode(params)}}\n';

class SocketTask {
  SocketTask({required this.isSubscription, this.completer, this.subject});

  bool isSubscription;
  Completer? completer; // for non-subscriptions
  BehaviorSubject? subject; // for subscriptions
}

class ElectrumClient {
  ElectrumClient()
      : _id = 0,
        _isConnected = false,
        _tasks = {},
        unterminatedString = '';

  static const connectionTimeout = Duration(seconds: 5);
  static const aliveTimerDuration = Duration(seconds: 2);

  bool get isConnected => _isConnected;
  Socket? socket;
  void Function(bool)? onConnectionStatusChange;
  int _id;
  final Map<String, SocketTask> _tasks;
  bool _isConnected;
  Timer? _aliveTimer;
  String unterminatedString;

  Future<void> connectToUri(Uri uri) async =>
      await connect(host: uri.host, port: uri.port);

  Future<void> connect({required String host, required int port}) async {
    try {
      await socket?.close();
    } catch (_) {}

    socket = await SecureSocket.connect(host, port,
        timeout: connectionTimeout, onBadCertificate: (_) => true);
    _setIsConnected(true);

    socket?.listen((Uint8List event) {
      try {
        final response =
            json.decode(utf8.decode(event.toList())) as Map<String, Object>;
        _handleResponse(response);
      } on FormatException catch (e) {
        final msg = e.message.toLowerCase();

        if (e.source is String) {
          unterminatedString += e.source as String;
        }

        if (msg.contains("not a subtype of type")) {
          unterminatedString += e.source as String;
          return;
        }

        if (isJSONStringCorrect(unterminatedString)) {
          final response =
              json.decode(unterminatedString) as Map<String, Object>;
          _handleResponse(response);
          unterminatedString = '';
        }
      } on TypeError catch (e) {
        if (!e.toString().contains('Map<String, Object>')) {
          return;
        }

        final source = utf8.decode(event.toList());
        unterminatedString += source;

        if (isJSONStringCorrect(unterminatedString)) {
          final response =
              json.decode(unterminatedString) as Map<String, Object>;
          _handleResponse(response);
          unterminatedString = '';
        }
      } catch (e) {
        print(e.toString());
      }
    }, onError: (Object error) {
      print(error.toString());
      _setIsConnected(false);
    }, onDone: () {
      _setIsConnected(false);
    });
    keepAlive();
  }

  void keepAlive() {
    _aliveTimer?.cancel();
    _aliveTimer = Timer.periodic(aliveTimerDuration, (_) async => ping());
  }

  Future<void> ping() async {
    try {
      await callWithTimeout(method: 'server.ping');
      _setIsConnected(true);
    } on RequestFailedTimeoutException catch (_) {
      _setIsConnected(false);
    }
  }

  Future<List<String>> version() =>
      call(method: 'server.version').then((dynamic result) {
        if (result is List) {
          return result.map((dynamic val) => val.toString()).toList();
        }

        return [];
      });

  Future<Map<String, Object>> getBalance(String scriptHash) =>
      call(method: 'blockchain.scripthash.get_balance', params: [scriptHash])
          .then((dynamic result) {
        if (result is Map<String, Object>) {
          return result;
        }

        return <String, Object>{};
      });

  Future<dynamic> call(
      {required String method, List<Object> params = const []}) async {
    final completer = Completer<dynamic>();
    _id += 1;
    final id = _id;
    _registryTask(id, completer);
    socket?.write(jsonrpc(method: method, id: id, params: params));

    return completer.future;
  }

  Future<dynamic> callWithTimeout(
      {required String method,
      List<Object> params = const [],
      int timeout = 2000}) async {
    final completer = Completer<dynamic>();
    _id += 1;
    final id = _id;
    _registryTask(id, completer);
    socket?.write(jsonrpc(method: method, id: id, params: params));
    Timer(Duration(milliseconds: timeout), () {
      if (!completer.isCompleted) {
        completer.completeError(RequestFailedTimeoutException(method, id));
      }
    });

    return completer.future;
  }

  Future<void> close() async {
    _aliveTimer?.cancel();
    await socket?.close();
    onConnectionStatusChange = null;
  }

  void _registryTask(int id, Completer completer) => _tasks[id.toString()] =
      SocketTask(completer: completer, isSubscription: false);

  void _regisrySubscription(String id, BehaviorSubject subject) =>
      _tasks[id] = SocketTask(subject: subject, isSubscription: true);

  void _finish(String id, Object? data) {
    if (!_tasks.containsKey(id) || data == null) {
      return;
    }

    if (!(_tasks[id]?.completer?.isCompleted ?? false)) {
      _tasks[id]?.completer?.complete(data);
    }

    if (!(_tasks[id]?.isSubscription ?? false)) {
      _tasks.remove(id);
    } else {
      _tasks[id]?.subject?.add(data);
    }
  }

  void _methodHandler(
      {required String method, required Map<String, Object> request}) {
    switch (method) {
      case 'blockchain.scripthash.subscribe':
        final params = request['params'] as List<dynamic>;
        final scripthash = params.first as String;
        final id = 'blockchain.scripthash.subscribe:$scripthash';

        _tasks[id]?.subject?.add(params.last);
        break;
      default:
        break;
    }
  }

  void _setIsConnected(bool isConnected) {
    if (_isConnected != isConnected) {
      onConnectionStatusChange?.call(isConnected);
    }

    _isConnected = isConnected;
  }

  void _handleResponse(Map<String, Object> response) {
    final method = response['method'];
    final id = response['id'] as String;
    final result = response['result'];

    if (method is String) {
      _methodHandler(method: method, request: response);
      return;
    }

    _finish(id, result);
  }
}

// FIXME: move me
bool isJSONStringCorrect(String source) {
  try {
    json.decode(source);
    return true;
  } catch (_) {
    return false;
  }
}

class RequestFailedTimeoutException implements Exception {
  RequestFailedTimeoutException(this.method, this.id);

  final String method;
  final int id;
}
