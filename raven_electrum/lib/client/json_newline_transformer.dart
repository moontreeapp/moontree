import 'dart:convert';

import 'package:async/async.dart';

import 'package:stream_channel/stream_channel.dart';

/// A [StreamChannelTransformer] similar to the default jsonDocument
/// transformer that is built in to stream_channel, but adds a newline
/// at the end of the JSON document, per Electrum's RPC requirement.
final StreamChannelTransformer<Object?, String> jsonNewlineDocument =
    _JsonNewlineTransformer();

class _JsonNewlineTransformer
    implements StreamChannelTransformer<Object?, String> {
  String inCache = "";
  int bracketCount = 0;

  dynamic parseInAndMaybeReturn(String data) {
    for (var rune in data.runes) {
      var character = String.fromCharCode(rune);
      if (character == '{') {
        bracketCount += 1;
      } else if (character == '}') {
        bracketCount -= 1;
      }
    }
    inCache += data;
    if (bracketCount == 0) {
      var ret = jsonDecode(inCache);
      inCache = '';
      return ret;
    }
  }

  _JsonNewlineTransformer();

  @override
  StreamChannel<Object?> bind(StreamChannel<String> channel) {
    var stream = channel.stream.map(parseInAndMaybeReturn);
    var sink = StreamSinkTransformer<Object, String>.fromHandlers(
        handleData: (data, sink) {
      if ((data as Map).containsKey('error')) {
        print('ERROR @ '
            'raven_electrum.lib.client.json_newline_transformer.dart: $data');
      }
      sink.add(jsonEncode(data) + '\n');
    }).bind(channel.sink);
    return StreamChannel.withCloseGuarantee(stream, sink);
  }
}
