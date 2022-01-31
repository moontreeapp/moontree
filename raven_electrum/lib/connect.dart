import 'dart:io' as io;
import 'dart:convert' as convert;

import 'package:stream_channel/stream_channel.dart';
// ignore: implementation_imports
import 'package:json_rpc_2/src/utils.dart' as utils;

import 'client/json_newline_transformer.dart';

const connectionTimeout = Duration(seconds: 5);
const aliveTimerDuration = Duration(seconds: 2);

Future<StreamChannel> connect(String host,
    {int port = 50002,
    Duration connectionTimeout = connectionTimeout,
    Duration aliveTimerDuration = aliveTimerDuration,
    bool acceptUnverified = true}) async {
  var socket = await io.SecureSocket.connect(host, port,
      timeout: connectionTimeout,
      onBadCertificate: acceptUnverified ? (_) => true : null);
  var channel = StreamChannel(socket.cast<List<int>>(), socket);
  var channelUtf8 =
      channel.transform(StreamChannelTransformer.fromCodec(convert.utf8));
  var channelJson = jsonNewlineDocument
      .bind(channelUtf8)
      .transformStream(utils.ignoreFormatExceptions);
  return channelJson;
}
