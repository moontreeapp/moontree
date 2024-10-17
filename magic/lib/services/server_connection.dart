import 'dart:convert';
import 'dart:developer';
import 'dart:async';
import 'package:magic/cubits/cubit.dart';
import 'package:magic/cubits/toast/cubit.dart';
import 'package:magic/utils/log.dart';
import 'package:web_socket_client/web_socket_client.dart';

class WebSocketEndpoint {
  final String endpoint;
  final Map<String, dynamic>? params;

  WebSocketEndpoint({required this.endpoint, this.params});

  String toJson() {
    if (params == null) {
      return jsonEncode({'endpoint': endpoint});
    }
    return jsonEncode({
      'endpoint': endpoint,
      'params': params ?? {},
    });
  }
}

/// Web Socket Connection
class WebSocketConnection {
  static WebSocketConnection? websocket;

  /// Web socket instance
  WebSocket? socket;

  /// Connection state
  static ConnectionState state = const Disconnected();

  /// Connection state string
  static String stateString = 'DD';

  /// Stream listen
  StreamController<String> stream = StreamController.broadcast(sync: true);

  /// Send listen data in queue
  List<String> sendDataQueue = [];
  factory WebSocketConnection() {
    return websocket ??= WebSocketConnection._internal();
  }
  WebSocketConnection._internal() {
    _init();
  }

  /// Init websocket connection
  Future<void> _init() async {
    try {
      /// websocket server url parse
      socket = WebSocket(
        Uri.parse('ws://app.moontree.com:8181/socket'),
        pingInterval: const Duration(seconds: 5),
        backoff: const ConstantBackoff(Duration(seconds: 5)),
      );
      _listenConnectionState();
    } catch (e, t) {
      log(
        'Websocket Exception => $e :: $t',
        name: 'WebsocketConnection',
      );
    }
  }

  Future<void> sendDataToServer(String data) async {
    see('sending', data);
    if (state is Connected || state is Reconnected) {
      socket?.send(data);
    } else {
      sendDataQueue.add(data);
    }
  }

  Future<void> sendEndpoint(WebSocketEndpoint endpoint) async {
    await sendDataToServer(endpoint.toJson());
  }

  void _listenEvents() {
    socket?.messages.listen(_listener);
  }

  void _listenConnectionState() {
    socket?.connection.listen(
      (event) {
        state = event;
        var stateName = event.runtimeType.toString();
        stateString = '${stateName[0]}${stateName[stateName.length - 1]}';
        if (event is Connected) {
          _listenEvents();
          _processSendDataQueue();
        } else if (event is Reconnected) {
          _processSendDataQueue();
        }
      },
    );
  }

  void _processSendDataQueue() {
    if (sendDataQueue.isNotEmpty) {
      for (final String data in sendDataQueue) {
        sendDataToServer(data);
      }
    }
  }

  void _listener(dynamic message) {
    try {
      stream.add(message);
      final msg = jsonDecode(message) as Map<String, dynamic>;
      if (msg['endpoint'] == 'pair.prove' && msg['result'] == "success") {
        cubits.toast.flash(
            msg: const ToastMessage(
          title: 'Pair with Magic on Chrome:',
          text: 'Successful',
          force: true,
        ));
      } else if (msg['endpoint'] == 'pair.prove' && msg['result'] == 'error') {
        cubits.toast.flash(
            msg: ToastMessage(
          title: 'Pairing Failed:',
          text: msg['error'],
          force: true,
        ));
      }
      log(
        "$message",
        name: 'WebSocketConnection',
      );
    } on Exception catch (e, t) {
      log(
        'Websocket exception => $e => Trace :: $t',
        name: 'WebsocketConnection',
      );
    }
  }

  void closeConnection() {
    socket?.close(1000, 'CLOSE_NORMAL');
    stream.close();
  }
}
