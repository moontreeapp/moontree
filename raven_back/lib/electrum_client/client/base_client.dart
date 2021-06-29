import 'dart:async';

import 'package:pedantic/pedantic.dart';
import 'package:json_rpc_2/json_rpc_2.dart' as rpc;
import 'package:stream_channel/stream_channel.dart';

/// The BaseClient class must be given an open channel to the server, which it
/// will use to make requests (or close the channel). We intentionally keep the
/// channel generic so that we can, for example, inject a mock server and write
/// tests against it. Normally, the channel will be derived from a SecureSocket
/// via TCP (see [connect.dart]).
///
/// Example:
///   var client = BaseClient(await connect('testnet.rvn.rocks'));
///
class BaseClient {
  /// We use a Peer here--which implements both Server and Client sides of a
  /// Remote Procedure Call (RPC) interface--to communicate with an ElectrumX
  /// Ravencoin server. We do so because we need:
  ///
  /// - the Client side for the basic ability to call 'procedures' on the
  ///   remote server (e.g. 'blockchain.scripthash.get_balance');
  ///
  /// - the Server side so that when we can subscribe to an ongoing stream of
  ///   updates (e.g. 'blockchain.headers.subscribe'). The remote server can
  ///   notify us of an update by calling our registered 'procedures'.
  ///
  /// The ElectrumX specification requires that notifications from the server
  /// use procedure names that match the initiating subscribe call. For example:
  ///
  ///   We can start a subscription by calling `blockchain.scripthash.subscribe`
  ///   and the server will subsequently notify us uf status changes by
  ///   calling this client's matching `blockchain.scripthash.subscribe`
  ///   procedure.
  ///
  /// Note that the BaseClient class does not implement subscriptions.
  ///
  late rpc.Peer peer;

  BaseClient(StreamChannel channel, {rpc.ErrorCallback? onUnhandledError}) {
    peer = rpc.Peer.withoutJson(channel,
        onUnhandledError: onUnhandledError ?? _handleError);
    unawaited(peer.listen());
  }

  Future<void> close() async {
    return peer.close();
  }

  Future request(String method, [parameters]) async {
    return await peer.sendRequest(method, parameters);
  }

  void _handleError(error, trace) {
    print('error!');
    print(error);
  }
}
