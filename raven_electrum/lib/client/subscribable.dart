import 'dart:convert';

import 'package:json_rpc_2/json_rpc_2.dart';

class Subscribable {
  /// The `methodPrefix` is the electrum RPC method, minus '.subscribe' suffix.
  final String methodPrefix;

  /// The number of params that make up the 'unique' request signature that can
  /// be matched to notification signature. For example,
  /// blockchain.scripthash.subscribe has a request signature that looks like
  /// this:
  ///   [scriptHash]
  ///
  /// Meanwhile, the notification signature looks like this:
  ///   [scriptHash, status]
  ///
  /// The `paramsCount` should be set to `1` to slice just the first param.
  final int paramsCount;

  Subscribable(this.methodPrefix, this.paramsCount);

  String get methodSubscribe => '$methodPrefix.subscribe';
  String get methodUnsubscribe => '$methodPrefix.unsubscribe';

  /// Returns a matching key, that can be used to match the original request to
  /// subsequent notifications.
  String key(Parameters? params) {
    if (params == null) {
      return '$methodPrefix[]';
    } else {
      var slice = params.asList.sublist(0, paramsCount);
      var json = jsonEncode(slice);
      return '$methodPrefix$json';
    }
  }

  Map notificationResult(Parameters params) {
    return params[paramsCount].valueOr({});
  }

  static String getMethodPrefix(String method) {
    return method.replaceFirst('.subscribe', '');
  }
}
