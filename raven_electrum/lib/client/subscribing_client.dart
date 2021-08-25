import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';

import 'base_client.dart';
import 'subscribable.dart';

export 'subscribable.dart';

// Maintain a list of registered Subscribables, one per RPC method prefix
final Map<String, Subscribable> _subscribables = {};
void registerSubscribable(String methodPrefix, int paramsCount) {
  if (!_subscribables.containsKey(methodPrefix)) {
    var subscribable = Subscribable(methodPrefix, paramsCount);
    _subscribables[methodPrefix] = subscribable;
  }
}

class SubscribingClient extends BaseClient {
  final Map<String, List<StreamController>> _subscriptions = {};

  SubscribingClient(channel) : super(channel) {
    // This "fallback" handles all valid notifications from the server
    peer.registerFallback((Parameters params) async {
      var methodPrefix = Subscribable.getMethodPrefix(params.method);
      var subscribable = _subscribables[methodPrefix];
      if (subscribable == null) {
        throw RpcException.methodNotFound(methodPrefix);
      }

      var key = subscribable.key(params.asList);
      var controllers = _subscriptions[key] ?? [];
      try {
        var result = subscribable.notificationResult(params.asList);
        for (var controller in controllers) {
          controller.sink.add(result);
        }
      } catch (err) {
        for (var controller in controllers) {
          controller.sink.addError(err);
        }
      }
    });
  }

  StreamController<T> makeSubscription<T>(
      Subscribable subscribable, List params) {
    var key = subscribable.key(params);
    var controllers = _subscriptions[key];
    var newController = StreamController<T>();
    if (controllers != null) {
      controllers.add(newController);
    } else {
      _subscriptions[key] = [newController];
    }

    return newController;
  }

  Stream<T> subscribe<T>(String methodPrefix, [List params = const []]) {
    var subscribable = _subscribables[methodPrefix];
    if (subscribable == null) {
      throw RpcException.methodNotFound(methodPrefix);
    }

    var controller = makeSubscription<T>(subscribable, params);
    request(subscribable.methodSubscribe, params).then((result) {
      controller.sink.add(result);
    });

    return controller.stream;
  }
}
