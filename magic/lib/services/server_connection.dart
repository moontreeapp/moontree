import 'dart:developer';
import 'dart:async';
import 'package:web_socket_client/web_socket_client.dart';

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
  StreamController<dynamic> stream = StreamController.broadcast(sync: true);

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
      //Todo: Add your websocket server url
      final wsUrl = Uri.parse('');
      socket = WebSocket(
        wsUrl,
        pingInterval: const Duration(seconds: 5),
        backoff: const ConstantBackoff(
          Duration(seconds: 5),
        ),
      );
      _listenConnectionState();
    } catch (e, t) {
      log(
        'Websocket Exception => $e :: $t',
        name: 'WebsocketConnection',
      );
    }
  }

  /// Send data to server
  Future<void> sendDataToServer(String data) async {
    if (state is Connected || state is Reconnected) {
      socket?.send(data);
    } else {
      sendDataQueue.add(data);
    }
  }

  /// Listen events
  void _listenEvents() {
    /// listener
    socket?.messages.listen(_listener);
  }

  /// Listen connection state
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

  /// for closing connection
  void closeConnection() {
    socket?.close(1000, 'CLOSE_NORMAL');
    stream.close();
  }
}
