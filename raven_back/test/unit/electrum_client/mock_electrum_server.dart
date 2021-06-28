import 'dart:async';

import 'package:stream_channel/stream_channel.dart';

/// A "mock" Electrum Server that simply responds with whatever the tests
/// want it to respond with.
///
/// Note: this server does not serialize incoming or outgoing data; rather,
///       it works directly with Dart objects. Therefore, there are no UTF8 or
///       JSON transformers operating as they would in a real server.
class MockElectrumServer {
  StreamController incomingController = StreamController();
  StreamController outgoingController = StreamController();
  late StreamChannel channel;
  int _id = 0;

  MockElectrumServer() {
    channel = StreamChannel.withGuarantees(
        incomingController.stream, outgoingController);

    // Show validation errors, if present
    outgoing.first.then((response) {
      if (response is Map && response.containsKey('error')) {
        print(response['error']);
      }
    });
  }

  /// The data "incoming" from the server to the client.
  StreamSink get incoming => incomingController.sink;

  Stream get outgoing => outgoingController.stream;

  /// for tests: indicate how the server should respond to the next request
  void willRespondWith(method, result, [id]) {
    incoming.add(prepareResponse(method, result, id));
  }

  /// for tests: send a notification to the client (i.e. a single message, which
  /// can be used to simulate a subscription)
  void notifyClient(method, [params]) {
    incoming.add(prepareNotification(method, params));
  }

  Map prepareResponse(method, result, [id]) =>
      {'jsonrpc': '2.0', 'method': method, 'id': id ?? _id++, 'result': result};

  Map prepareNotification(method, params) =>
      {'jsonrpc': '2.0', 'method': method, 'params': params ?? []};
}
