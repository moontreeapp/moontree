import 'dart:async';

import 'package:json_rpc_2/json_rpc_2.dart';

import './base_client.dart';
import './subscribable.dart';

export './subscribable.dart';

class SubscribingClient extends BaseClient {
  final Map<String, Subscribable> _subscribables = {};
  final Map<String, List<StreamController>> _subscriptions = {};

  SubscribingClient(channel) : super(channel) {
    // This "fallback" handles all valid notifications from the server
    peer.registerFallback((Parameters params) async {
      var methodPrefix = Subscribable.getMethodPrefix(params.method);
      var subscribable = _subscribables[methodPrefix];
      if (subscribable == null) {
        throw RpcException.methodNotFound(methodPrefix);
      }

      var key = subscribable.key(params);
      var controllers = _subscriptions[key] ?? [];

      var result = subscribable.notificationResult(params);
      for (var controller in controllers) {
        // NOTE: So far, only the first parameter of the notification
        controller.sink.add(result);
      }
    });
  }

  void registerSubscribable(Subscribable subscribable) {
    _subscribables[subscribable.methodPrefix] = subscribable;
  }

  StreamController makeSubscription(
      Subscribable subscribable, Parameters? params) {
    var key = subscribable.key(params);
    var controllers = _subscriptions[key];
    var newController = StreamController();
    if (controllers != null) {
      controllers.add(newController);
    } else {
      _subscriptions[key] = [newController];
    }

    return newController;
  }

  Stream subscribe(String methodPrefix, [Parameters? params]) {
    var subscribable = _subscribables[methodPrefix];
    if (subscribable == null) {
      throw RpcException.methodNotFound(methodPrefix);
    }

    var controller = makeSubscription(subscribable, params);
    request(subscribable.methodSubscribe, params).then((result) {
      controller.sink.add(result);
    });

    return controller.stream;
  }
}
