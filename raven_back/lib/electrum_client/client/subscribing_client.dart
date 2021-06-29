import 'dart:async';
import 'dart:convert' as convert;

import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;

import 'package:raven/electrum_client/client/base_client.dart';

typedef KeyRetriever = String Function(rpc.Parameters params);

class Subscribable {
  final String methodPrefix;
  late final KeyRetriever _getKeyFromParams;

  Subscribable(this.methodPrefix, [getKeyFromParams]) {
    _getKeyFromParams = getKeyFromParams ?? (_) => '';
  }

  String key(params) => '$methodPrefix:${_getKeyFromParams(params)}';
}

class SubscribingClient extends BaseClient {
  final Map<String, Subscribable> _subscribables = {};
  final Map<String, List<StreamController>> _subscriptions = {};

  SubscribingClient(channel) : super(channel) {
    // This "fallback" handles all valid notifications from the server
    peer.registerFallback((rpc.Parameters params) async {
      print('fallback: ${params.method}, ${params.value}');

      var subscribable = _subscribables[params.method];
      if (subscribable == null) {
        throw rpc.RpcException.methodNotFound(params.method);
      }
      var key = subscribable.key(params);
      var controllers = _subscriptions[key] ?? [];

      for (var controller in controllers) {
        controller.sink.add(params);
      }
    });
  }

  void registerSubscribable(Subscribable subscribable) {
    var method = '${subscribable.methodPrefix}.subscribe';
    _subscribables[method] = subscribable;
  }

  void addSubscription(String method, StreamController controller) {
    var controllers = _subscriptions[method];
    if (controllers != null) {
      controllers.add(controller);
    } else {
      _subscriptions[method] = [controller];
    }
  }

  Stream subscribe(String methodPrefix, [parameters]) {
    var method = '$methodPrefix.subscribe';
    if (!_subscribables.containsKey(method)) {
      throw rpc.RpcException.methodNotFound(method);
    }

    var controller = StreamController();
    addSubscription(method, controller);
    request(method, parameters).then((json) {
      controller.sink.add(json);
    });

    return controller.stream;
  }
}
