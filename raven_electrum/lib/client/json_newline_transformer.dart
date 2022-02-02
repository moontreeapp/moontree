import 'dart:convert';

import 'package:async/async.dart';

import 'package:stream_channel/stream_channel.dart';

import 'package:json_stream_parser/json_stream_parser.dart';

/// A [StreamChannelTransformer] similar to the default jsonDocument
/// transformer that is built in to stream_channel, but adds a newline
/// at the end of the JSON document, per Electrum's RPC requirement.
final StreamChannelTransformer<Object?, String> jsonNewlineDocument = const _JsonNewlineTransformer();

class _JsonNewlineTransformer implements StreamChannelTransformer<Object?, String> {
  const _JsonNewlineTransformer();
  
  @override
  StreamChannel<Object?> bind(StreamChannel<String> channel) {
    var stream = channel.stream.transform(ContinuousJsonDecoder());
    var sink = StreamSinkTransformer<Object, String>.fromHandlers(
      handleData: (data, sink) {
        if ((data as Map).containsKey('error')) {
          /// todo: fix lower layers so this never happens.
          print('ERROR @ '
            'raven_electrum.lib.client.json_newline_transformer.dart: $data');
        } else {
          sink.add(jsonEncode(data) + '\n');
        }
      }
    ).bind(channel.sink);
    return StreamChannel.withCloseGuarantee(stream, sink);
  }
}
