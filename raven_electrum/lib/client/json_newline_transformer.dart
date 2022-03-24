// ignore_for_file: constant_identifier_names

import 'dart:convert';

import "dart:typed_data";

import 'package:async/async.dart';

import 'package:stream_channel/stream_channel.dart';

/// A [StreamChannelTransformer] similar to the default jsonDocument
/// transformer that is built in to stream_channel, but adds a newline
/// at the end of the JSON document, per Electrum's RPC requirement.
final StreamChannelTransformer<Object?, String> jsonNewlineDocument =
    const _JsonNewlineTransformer();

class _JsonNewlineTransformer
    implements StreamChannelTransformer<Object?, String> {
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
    }).bind(channel.sink);
    return StreamChannel.withCloseGuarantee(stream, sink);
  }
}

// The follow is copied from
// https://github.com/dart-lang/sdk/blob/9df38b50da5f6442f51c903182da7880abc45fca/sdk/lib/convert/json.dart#L590
// and
// https://github.com/dart-lang/sdk/blob/main/sdk/lib/_internal/vm/lib/convert_patch.dart
// modified to allow the JsonDecoder to return json objects every JSON END_STATE instead of
// on stream closure

// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

const powersOfTen = [
  1.0,
  /*  0 */
  10.0,
  100.0,
  1000.0,
  10000.0,
  100000.0,
  /*  5 */
  1000000.0,
  10000000.0,
  100000000.0,
  1000000000.0,
  10000000000.0,
  /* 10 */
  100000000000.0,
  1000000000000.0,
  10000000000000.0,
  100000000000000.0,
  1000000000000000.0,
  /*  15 */
  10000000000000000.0,
  100000000000000000.0,
  1000000000000000000.0,
  10000000000000000000.0,
  100000000000000000000.0,
  /*  20 */
  1000000000000000000000.0,
  10000000000000000000000.0,
];

/// This class parses JSON strings and builds the corresponding objects.
///
/// A JSON input must be the JSON encoding of a single JSON value,
/// which can be a list or map containing other values.
///
/// Throws [FormatException] if the input is not valid JSON text.
///
/// Example:
/// ```dart
/// const JsonDecoder decoder = JsonDecoder();
///
/// const String jsonString = '''
///   {
///     "data": [{"text": "foo", "value": 1 },
///              {"text": "bar", "value": 2 }],
///     "text": "Dart"
///   }
/// ''';
///
/// final Map<String, dynamic> object = decoder.convert(jsonString);
///
/// final item = object['data'][0];
/// print(item['text']); // foo
/// print(item['value']); // 1
///
/// print(object['text']); // Dart
/// ```
///
/// When used as a [StreamTransformer], the input stream may emit
/// multiple strings. The concatenation of all of these strings must
/// be a valid JSON encoding of a single JSON value.
class ContinuousJsonDecoder extends Converter<String, Object?> {
  final Object? Function(Object? key, Object? value)? _reviver;

  /// Constructs a new JsonDecoder.
  ///
  /// The [reviver] may be `null`.
  const ContinuousJsonDecoder(
      [Object? Function(Object? key, Object? value)? reviver])
      : _reviver = reviver;

  /// Converts the given JSON-string [input] to its corresponding object.
  ///
  /// Parsed JSON values are of the types [num], [String], [bool], [Null],
  /// [List]s of parsed JSON values or [Map]s from [String] to parsed JSON
  /// values.
  ///
  /// If `this` was initialized with a reviver, then the parsing operation
  /// invokes the reviver on every object or list property that has been parsed.
  /// The arguments are the property name ([String]) or list index ([int]), and
  /// the value is the parsed value. The return value of the reviver is used as
  /// the value of that property instead the parsed value.
  ///
  /// Throws [FormatException] if the input is not valid JSON text.
  @override
  dynamic convert(String input) => _parseJson(input, _reviver);

  /// Starts a conversion from a chunked JSON string to its corresponding object.
  ///
  /// The output [sink] receives exactly one decoded element through `add`.
  @override
  StringConversionSink startChunkedConversion(Sink<Object?> sink) {
    return _JsonStringDecoderSink(_reviver, sink);
  }

  // Override the base class's bind, to provide a better type.
  @override
  Stream<Object?> bind(Stream<String> stream) => super.bind(stream);
}

// The following is from https://github.com/dart-lang/sdk/blob/main/sdk/lib/_internal/vm/lib/convert_patch.dart
dynamic _parseJson(
    String source, Object? Function(Object? key, Object? value)? reviver) {
  _BuildJsonListener listener;
  if (reviver == null) {
    listener = _BuildJsonListener();
  } else {
    listener = _ReviverJsonListener(reviver);
  }
  var parser = _JsonStringParser(listener, null);
  parser.chunk = source;
  parser.chunkEnd = source.length;
  parser.parse(0);
  parser.close();
  return listener.result;
}

// Simple API for JSON parsing.

/// Listener for parsing events from [_ChunkedJsonParser].
abstract class _JsonListener {
  /// Stack used to handle nested containers.
  ///
  /// The current container is pushed on the stack when a new one is
  /// started. If the container is a [Map], there is also a current [key]
  /// which is also stored on the stack.
  final List<Object?> stack = [];

  void handleString(String value) {}
  void handleNumber(num value) {}
  void handleBool(bool value) {}
  void handleNull() {}
  void beginObject() {}
  void propertyName() {}
  void propertyValue() {}
  void endObject() {}
  void beginArray() {}
  void arrayElement() {}
  void endArray() {}

  /// Read out the final result of parsing a JSON string.
  ///
  /// Must only be called when the entire input has been parsed.
  dynamic get result;
}

/// A [_JsonListener] that builds data objects from the parser events.
///
/// This is a simple stack-based object builder. It keeps the most recently
/// seen value in a variable, and uses it depending on the following event.
class _BuildJsonListener extends _JsonListener {
  /// The current [Map] or [List] being built. */
  dynamic currentContainer;

  /// The most recently read property key. */
  String key = '';

  /// The most recently read value. */
  dynamic value;

  /// Pushes the currently active container (and key, if a [Map]). */
  void pushContainer() {
    if (currentContainer is Map) stack.add(key);
    stack.add(currentContainer);
  }

  /// Pops the top container from the [stack], including a key if applicable. */
  void popContainer() {
    value = currentContainer;
    currentContainer = stack.removeLast();
    if (currentContainer is Map) key = stack.removeLast() as String;
  }

  @override
  void handleString(String value) {
    this.value = value;
  }

  @override
  void handleNumber(num value) {
    this.value = value;
  }

  @override
  void handleBool(bool value) {
    this.value = value;
  }

  @override
  void handleNull() {
    value = null;
  }

  @override
  void beginObject() {
    pushContainer();
    currentContainer = <String, dynamic>{};
  }

  @override
  void propertyName() {
    key = value;
    value = null;
  }

  @override
  void propertyValue() {
    Map map = currentContainer;
    map[key] = value;
    key = '';
    value = null;
  }

  @override
  void endObject() {
    popContainer();
  }

  @override
  void beginArray() {
    pushContainer();
    currentContainer = [];
  }

  @override
  void arrayElement() {
    currentContainer.add(value);
    value = null;
  }

  @override
  void endArray() {
    popContainer();
  }

  /// Read out the final result of parsing a JSON string. */
  @override
  dynamic get result {
    assert(currentContainer == null);
    return value;
  }
}

class _ReviverJsonListener extends _BuildJsonListener {
  final Object? Function(Object? key, Object? value) reviver;
  _ReviverJsonListener(this.reviver);

  @override
  void arrayElement() {
    List list = currentContainer;
    value = reviver(list.length, value);
    super.arrayElement();
  }

  @override
  void propertyValue() {
    value = reviver(key, value);
    super.propertyValue();
  }

  @override
  dynamic get result {
    return reviver(null, value);
  }
}

/// Buffer holding parts of a numeral.
///
/// The buffer contains the characters of a JSON number.
/// These are all ASCII, so an [Uint8List] is used as backing store.
///
/// This buffer is used when a JSON number is split between separate chunks.
class _NumberBuffer {
  static const int minCapacity = 16;
  static const int defaultOverhead = 5;
  Uint8List list;
  int length = 0;
  _NumberBuffer(int initialCapacity)
      : list = Uint8List(_initialCapacity(initialCapacity));

  int get capacity => list.length;

  // Pick an initial capacity greater than the first part's size.
  // The typical use case has two parts, this is the attempt at
  // guessing the size of the second part without overdoing it.
  // The default estimate of the second part is [defaultOverhead],
  // then round to multiplum of four, and return the result,
  // or [minCapacity] if that is greater.
  static int _initialCapacity(int minCapacity) {
    minCapacity += defaultOverhead;
    if (minCapacity < _NumberBuffer.minCapacity) {
      return _NumberBuffer.minCapacity;
    }
    minCapacity = (minCapacity + 3) & ~3; // Round to multiple of four.
    return minCapacity;
  }

  // Grows to the exact size asked for.
  void ensureCapacity(int newCapacity) {
    Uint8List list = this.list;
    if (newCapacity <= list.length) return;
    Uint8List newList = Uint8List(newCapacity);
    newList.setRange(0, list.length, list, 0);
    this.list = newList;
  }

  String getString() {
    String result = String.fromCharCodes(list, 0, length);
    return result;
  }

  // TODO(lrn): See if parsing of numbers can be abstracted to something
  // not only working on strings, but also on char-code lists, without lossing
  // performance.
  num parseNum() => num.parse(getString());
  double parseDouble() => double.parse(getString());
}

/// Chunked JSON parser.
///
/// Receives inputs in chunks, gives access to individual parts of the input,
/// and stores input state between chunks.
///
/// Implementations include [String] and UTF-8 parsers.
abstract class _ChunkedJsonParser<T> {
  // A simple non-recursive state-based parser for JSON.
  //
  // Literal values accepted in states ARRAY_EMPTY, ARRAY_COMMA, OBJECT_COLON
  // and strings also in OBJECT_EMPTY, OBJECT_COMMA.
  //               VALUE  STRING  :  ,  }  ]        Transitions to
  // EMPTY            X      X                   -> END
  // ARRAY_EMPTY      X      X             @     -> ARRAY_VALUE / pop
  // ARRAY_VALUE                     @     @     -> ARRAY_COMMA / pop
  // ARRAY_COMMA      X      X                   -> ARRAY_VALUE
  // OBJECT_EMPTY            X          @        -> OBJECT_KEY / pop
  // OBJECT_KEY                   @              -> OBJECT_COLON
  // OBJECT_COLON     X      X                   -> OBJECT_VALUE
  // OBJECT_VALUE                    @  @        -> OBJECT_COMMA / pop
  // OBJECT_COMMA            X                   -> OBJECT_KEY
  // END
  // Starting a new array or object will push the current state. The "pop"
  // above means restoring this state and then marking it as an ended value.
  // X means generic handling, @ means special handling for just that
  // state - that is, values are handled generically, only punctuation
  // cares about the current state.
  // Values for states are chosen so bits 0 and 1 tell whether
  // a string/value is allowed, and setting bits 0 through 2 after a value
  // gets to the next state (not empty, doesn't allow a value).

  // State building-block constants.
  static const int TOP_LEVEL = 0;
  static const int INSIDE_ARRAY = 1;
  static const int INSIDE_OBJECT = 2;
  static const int AFTER_COLON = 3; // Always inside object.

  static const int ALLOW_STRING_MASK = 8; // Allowed if zero.
  static const int ALLOW_VALUE_MASK = 4; // Allowed if zero.
  static const int ALLOW_VALUE = 0;
  static const int STRING_ONLY = 4;
  static const int NO_VALUES = 12;

  // Objects and arrays are "empty" until their first property/element.
  // At this position, they may either have an entry or a close-bracket.
  static const int EMPTY = 0;
  static const int NON_EMPTY = 16;
  //static const int EMPTY_MASK = 16; // Empty if zero. //unused

  // Actual states               : Context | Is empty? | Next?
  static const int STATE_INITIAL = TOP_LEVEL | EMPTY | ALLOW_VALUE;
  static const int STATE_END = TOP_LEVEL | NON_EMPTY | NO_VALUES;

  static const int STATE_ARRAY_EMPTY = INSIDE_ARRAY | EMPTY | ALLOW_VALUE;
  static const int STATE_ARRAY_VALUE = INSIDE_ARRAY | NON_EMPTY | NO_VALUES;
  static const int STATE_ARRAY_COMMA = INSIDE_ARRAY | NON_EMPTY | ALLOW_VALUE;

  static const int STATE_OBJECT_EMPTY = INSIDE_OBJECT | EMPTY | STRING_ONLY;
  static const int STATE_OBJECT_KEY = INSIDE_OBJECT | NON_EMPTY | NO_VALUES;
  static const int STATE_OBJECT_COLON = AFTER_COLON | NON_EMPTY | ALLOW_VALUE;
  static const int STATE_OBJECT_VALUE = AFTER_COLON | NON_EMPTY | NO_VALUES;
  static const int STATE_OBJECT_COMMA = INSIDE_OBJECT | NON_EMPTY | STRING_ONLY;

  // Bits set in state after successfully reading a value.
  // This transitions the state to expect the next punctuation.
  static const int VALUE_READ_BITS = NON_EMPTY | NO_VALUES;

  // Character code constants.
  static const int BACKSPACE = 0x08;
  static const int TAB = 0x09;
  static const int NEWLINE = 0x0a;
  static const int CARRIAGE_RETURN = 0x0d;
  static const int FORM_FEED = 0x0c;
  static const int SPACE = 0x20;
  static const int QUOTE = 0x22;
  static const int PLUS = 0x2b;
  static const int COMMA = 0x2c;
  static const int MINUS = 0x2d;
  static const int DECIMALPOINT = 0x2e;
  static const int SLASH = 0x2f;
  static const int CHAR_0 = 0x30;
  //static const int CHAR_9 = 0x39; // unused
  static const int COLON = 0x3a;
  //static const int CHAR_E = 0x45; // unused
  static const int LBRACKET = 0x5b;
  static const int BACKSLASH = 0x5c;
  static const int RBRACKET = 0x5d;
  static const int CHAR_a = 0x61;
  static const int CHAR_b = 0x62;
  static const int CHAR_e = 0x65;
  static const int CHAR_f = 0x66;
  static const int CHAR_l = 0x6c;
  static const int CHAR_n = 0x6e;
  static const int CHAR_r = 0x72;
  static const int CHAR_s = 0x73;
  static const int CHAR_t = 0x74;
  static const int CHAR_u = 0x75;
  static const int LBRACE = 0x7b;
  static const int RBRACE = 0x7d;

  // State of partial value at chunk split.
  static const int NO_PARTIAL = 0;
  static const int PARTIAL_STRING = 1;
  static const int PARTIAL_NUMERAL = 2;
  static const int PARTIAL_KEYWORD = 3;
  static const int MASK_PARTIAL = 3;

  // Partial states for numerals. Values can be |'ed with PARTIAL_NUMERAL.
  static const int NUM_SIGN = 0; // After initial '-'.
  static const int NUM_ZERO = 4; // After '0' as first digit.
  static const int NUM_DIGIT = 8; // After digit, no '.' or 'e' seen.
  static const int NUM_DOT = 12; // After '.'.
  static const int NUM_DOT_DIGIT = 16; // After a decimal digit (after '.').
  static const int NUM_E = 20; // After 'e' or 'E'.
  static const int NUM_E_SIGN = 24; // After '-' or '+' after 'e' or 'E'.
  static const int NUM_E_DIGIT = 28; // After exponent digit.
  //static const int NUM_SUCCESS = 32; // Never stored as partial state. unused

  // Partial states for strings.
  static const int STR_PLAIN = 0; // Inside string, but not escape.
  static const int STR_ESCAPE = 4; // After '\'.
  static const int STR_U = 16; // After '\u' and 0-3 hex digits.
  static const int STR_U_COUNT_SHIFT = 2; // Hex digit count in bits 2-3.
  static const int STR_U_VALUE_SHIFT = 5; // Hex digit value in bits 5+.

  // Partial states for keywords.
  static const int KWD_TYPE_MASK = 12;
  static const int KWD_TYPE_SHIFT = 2;
  static const int KWD_NULL = 0; // Prefix of "null" seen.
  static const int KWD_TRUE = 4; // Prefix of "true" seen.
  static const int KWD_FALSE = 8; // Prefix of "false" seen.
  static const int KWD_BOM = 12; // Prefix of BOM seen.
  static const int KWD_COUNT_SHIFT = 4; // Prefix length in bits 4+.

  // Mask used to mask off two lower bits.
  static const int TWO_BIT_MASK = 3;

  final _JsonListener listener;
  final Sink<Object?>? _sink;

  // The current parsing state.
  int state = STATE_INITIAL;
  List<int> states = <int>[];

  /// Stores tokenizer state between chunks.
  ///
  /// This state is stored when a chunk stops in the middle of a
  /// token (string, numeral, boolean or null).
  ///
  /// The partial state is used to continue parsing on the next chunk.
  /// The previous chunk is not retained, any data needed are stored in
  /// this integer, or in the [buffer] field as a string-building buffer
  /// or a [_NumberBuffer].
  ///
  /// Prefix state stored in [prefixState] as bits.
  ///
  ///            ..00 : No partial value (NO_PARTIAL).
  ///
  ///         ..00001 : Partial string, not inside escape.
  ///         ..00101 : Partial string, after '\'.
  ///     ..vvvv1dd01 : Partial \u escape.
  ///                   The 'dd' bits (2-3) encode the number of hex digits seen.
  ///                   Bits 5-16 encode the value of the hex digits seen so far.
  ///
  ///        ..0ddd10 : Partial numeral.
  ///                   The `ddd` bits store the parts of in the numeral seen so
  ///                   far, as the constants `NUM_*` defined above.
  ///                   The characters of the numeral are stored in [buffer]
  ///                   as a [_NumberBuffer].
  ///
  ///      ..0ddd0011 : Partial 'null' keyword.
  ///      ..0ddd0111 : Partial 'true' keyword.
  ///      ..0ddd1011 : Partial 'false' keyword.
  ///      ..0ddd1111 : Partial UTF-8 BOM byte seqeuence ("\xEF\xBB\xBF").
  ///                   For all keywords, the `ddd` bits encode the number
  ///                   of letters seen.
  ///                   The BOM byte sequence is only used by [_JsonUtf8Parser],
  ///                   and only at the very beginning of input.
  int partialState = NO_PARTIAL;

  /// Extra data stored while parsing a primitive value.
  /// May be set during parsing, always set at chunk end if a value is partial.
  ///
  /// May contain a string buffer while parsing strings.
  dynamic buffer;

  _ChunkedJsonParser(this.listener, [this._sink]);

  /// Push the current parse [state] on a stack.
  ///
  /// State is pushed when a new array or object literal starts,
  /// so the parser can go back to the correct value when the literal ends.
  void saveState(int state) {
    states.add(state);
  }

  /// Restore a state pushed with [saveState].
  int restoreState() {
    return states.removeLast(); // Throws if empty.
  }

  /// Finalizes the parsing.
  ///
  /// Throws if the source read so far doesn't end up with a complete
  /// parsed value. That means it must not be inside a list or object
  /// literal, and any partial value read should also be a valid complete
  /// value.
  ///
  /// The only valid partial state is a number that ends in a digit, and
  /// only if the number is the entire JSON value being parsed
  /// (otherwise it would be inside a list or object).
  /// Such a number will be completed. Any other partial state is an error.
  void close() {
    if (partialState != NO_PARTIAL) {
      int partialType = partialState & MASK_PARTIAL;
      if (partialType == PARTIAL_NUMERAL) {
        int numState = partialState & ~MASK_PARTIAL;
        // A partial number might be a valid number if we know it's done.
        // There is an unnecessary overhead if input is a single number,
        // but this is assumed to be rare.
        _NumberBuffer buffer = this.buffer;
        this.buffer = null;
        finishChunkNumber(numState, 0, 0, buffer);
      } else if (partialType == PARTIAL_STRING) {
        fail(chunkEnd, "Unterminated string");
      } else {
        assert(partialType == PARTIAL_KEYWORD);
        fail(chunkEnd); // Incomplete literal.
      }
    }
    //Change to STATE_INITIAL because that is what we reset to.
    if (state != STATE_INITIAL) {
      fail(chunkEnd);
    }
  }

  /// Read out the result after successfully closing the parser.
  ///
  /// The parser is closed by calling [close] or calling [addSourceChunk] with
  /// `true` as second (`isLast`) argument.
  dynamic get result {
    return listener.result;
  }

  /// Sets the current source chunk. */
  set chunk(T source);

  /// Length of current chunk.
  ///
  /// The valid arguments to [getChar] are 0 .. `chunkEnd - 1`.
  int get chunkEnd;

  /// Returns the chunk itself.
  ///
  /// Only used by [fail] to include the chunk in the thrown [FormatException].
  T get chunk;

  /// Get charcacter/code unit of current chunk.
  ///
  /// The [index] must be non-negative and less than `chunkEnd`.
  /// In practive, [index] will be no smaller than the `start` argument passed
  /// to [parse].
  int getChar(int index);

  /// Copy ASCII characters from start to end of chunk into a list.
  ///
  /// Used for number buffer (always copies ASCII, so encoding is not important).
  void copyCharsToList(int start, int end, List<int> target, int offset);

  /// Build a string using input code units.
  ///
  /// Creates a string buffer and enables adding characters and slices
  /// to that buffer.
  /// The buffer is stored in the [buffer] field. If the string is unterminated,
  /// the same buffer is used to continue parsing in the next chunk.
  void beginString();

  /// Add single character code to string being built.
  ///
  /// Used for unparsed escape sequences.
  void addCharToString(int charCode);

  /// Adds slice of current chunk to string being built.
  ///
  /// The [start] positions is inclusive, [end] is exclusive.
  void addSliceToString(int start, int end);

  /// Finalizes the string being built and returns it as a String. */
  String endString();

  /// Extracts a literal string from a slice of the current chunk.
  ///
  /// No interpretation of the content is performed, except for converting
  /// the source format to string.
  /// This can be implemented more or less efficiently depending on the
  /// underlying source.
  ///
  /// This is used for string literals that contain no escapes.
  ///
  /// The [bits] integer is an upper bound on the code point in the range
  /// from `start` to `end`.
  /// Usually found by doing bitwise or of all the values.
  /// The function may choose to optimize depending on the value.
  String getString(int start, int end, int bits);

  /// Parse a slice of the current chunk as a number.
  ///
  /// Since integers have a maximal value, and we don't track the value
  /// in the buffer, a sequence of digits can be either an int or a double.
  /// The `num.parse` function does the right thing.
  ///
  /// The format is expected to be correct.
  num parseNum(int start, int end) {
    const int asciiBits = 0x7f; // Number literals are ASCII only.
    return num.parse(getString(start, end, asciiBits));
  }

  /// Parse a slice of the current chunk as a double.
  ///
  /// The format is expected to be correct.
  /// This is used by [parseNumber] when the double value cannot be
  /// built exactly during parsing.
  double parseDouble(int start, int end) {
    const int asciiBits = 0x7f; // Double literals are ASCII only.
    return double.parse(getString(start, end, asciiBits));
  }

  /// Continues parsing a partial value.
  int parsePartial(int position) {
    if (position == chunkEnd) return position;
    int partialState = this.partialState;
    assert(partialState != NO_PARTIAL);
    int partialType = partialState & MASK_PARTIAL;
    this.partialState = NO_PARTIAL;
    partialState = partialState & ~MASK_PARTIAL;
    assert(partialType != 0);
    if (partialType == PARTIAL_STRING) {
      position = parsePartialString(position, partialState);
    } else if (partialType == PARTIAL_NUMERAL) {
      position = parsePartialNumber(position, partialState);
    } else if (partialType == PARTIAL_KEYWORD) {
      position = parsePartialKeyword(position, partialState);
    }
    return position;
  }

  /// Parses the remainder of a number into the number buffer.
  ///
  /// Syntax is checked while pasing.
  /// Starts at position, which is expected to be the start of the chunk,
  /// and returns the index of the first non-number-literal character found,
  /// or chunkEnd if the entire chunk is a valid number continuation.
  /// Throws if a syntax error is detected.
  int parsePartialNumber(int position, int state) {
    int start = position;
    // Primitive implementation, can be optimized.
    _NumberBuffer buffer = this.buffer;
    this.buffer = null;
    int end = chunkEnd;
    toBailout:
    {
      if (position == end) break toBailout;
      int char = getChar(position);
      int digit = char ^ CHAR_0;
      if (state == NUM_SIGN) {
        if (digit <= 9) {
          if (digit == 0) {
            state = NUM_ZERO;
          } else {
            state = NUM_DIGIT;
          }
          position++;
          if (position == end) break toBailout;
          char = getChar(position);
          digit = char ^ CHAR_0;
        } else {
          fail(position);
        }
      }
      if (state == NUM_ZERO) {
        // JSON does not allow insignificant leading zeros (e.g., "09").
        if (digit <= 9) fail(position);
        state = NUM_DIGIT;
      }
      while (state == NUM_DIGIT) {
        if (digit > 9) {
          if (char == DECIMALPOINT) {
            state = NUM_DOT;
          } else if ((char | 0x20) == CHAR_e) {
            state = NUM_E;
          } else {
            finishChunkNumber(state, start, position, buffer);
            return position;
          }
        }
        position++;
        if (position == end) break toBailout;
        char = getChar(position);
        digit = char ^ CHAR_0;
      }
      if (state == NUM_DOT) {
        if (digit > 9) fail(position);
        state = NUM_DOT_DIGIT;
      }
      while (state == NUM_DOT_DIGIT) {
        if (digit > 9) {
          if ((char | 0x20) == CHAR_e) {
            state = NUM_E;
          } else {
            finishChunkNumber(state, start, position, buffer);
            return position;
          }
        }
        position++;
        if (position == end) break toBailout;
        char = getChar(position);
        digit = char ^ CHAR_0;
      }
      if (state == NUM_E) {
        if (char == PLUS || char == MINUS) {
          state = NUM_E_SIGN;
          position++;
          if (position == end) break toBailout;
          char = getChar(position);
          digit = char ^ CHAR_0;
        }
      }
      assert(state >= NUM_E);
      while (digit <= 9) {
        state = NUM_E_DIGIT;
        position++;
        if (position == end) break toBailout;
        char = getChar(position);
        digit = char ^ CHAR_0;
      }
      finishChunkNumber(state, start, position, buffer);
      return position;
    }
    // Bailout code in case the current chunk ends while parsing the numeral.
    assert(position == end);
    continueChunkNumber(state, start, buffer);
    return chunkEnd;
  }

  /// Continues parsing a partial string literal.
  ///
  /// Handles partial escapes and then hands the parsing off to
  /// [parseStringToBuffer].
  int parsePartialString(int position, int partialState) {
    if (partialState == STR_PLAIN) {
      return parseStringToBuffer(position);
    }
    if (partialState == STR_ESCAPE) {
      position = parseStringEscape(position);
      // parseStringEscape sets partialState if it sees the end.
      if (position == chunkEnd) return position;
      return parseStringToBuffer(position);
    }
    assert((partialState & STR_U) != 0);
    int value = partialState >> STR_U_VALUE_SHIFT;
    int count = (partialState >> STR_U_COUNT_SHIFT) & TWO_BIT_MASK;
    for (int i = count; i < 4; i++, position++) {
      if (position == chunkEnd) return chunkStringEscapeU(i, value);
      int char = getChar(position);
      int digit = parseHexDigit(char);
      if (digit < 0) fail(position, "Invalid hex digit");
      value = 16 * value + digit;
    }
    addCharToString(value);
    return parseStringToBuffer(position);
  }

  /// Continues parsing a partial keyword.
  int parsePartialKeyword(int position, int partialState) {
    int keywordType = partialState & KWD_TYPE_MASK;
    int count = partialState >> KWD_COUNT_SHIFT;
    int keywordTypeIndex = keywordType >> KWD_TYPE_SHIFT;
    String keyword =
        const ["null", "true", "false", "\xEF\xBB\xBF"][keywordTypeIndex];
    assert(count < keyword.length);
    do {
      if (position == chunkEnd) {
        this.partialState =
            PARTIAL_KEYWORD | keywordType | (count << KWD_COUNT_SHIFT);
        return chunkEnd;
      }
      int expectedChar = keyword.codeUnitAt(count);
      if (getChar(position) != expectedChar) {
        if (count == 0) {
          assert(keywordType == KWD_BOM);
          return position;
        }
        fail(position);
      }
      position++;
      count++;
    } while (count < keyword.length);
    if (keywordType == KWD_NULL) {
      listener.handleNull();
    } else if (keywordType != KWD_BOM) {
      listener.handleBool(keywordType == KWD_TRUE);
    }
    return position;
  }

  /// Convert hex-digit to its value. Returns -1 if char is not a hex digit. */
  int parseHexDigit(int char) {
    int digit = char ^ 0x30;
    if (digit <= 9) return digit;
    int letter = (char | 0x20) ^ 0x60;
    // values 1 .. 6 are 'a' through 'f'
    if (letter <= 6 && letter > 0) return letter + 9;
    return -1;
  }

  /// Parses the current chunk as a chunk of JSON.
  ///
  /// Starts parsing at [position] and continues until [chunkEnd].
  /// Continues parsing where the previous chunk (if any) ended.
  void parse(int position) {
    int length = chunkEnd;
    if (partialState != NO_PARTIAL) {
      position = parsePartial(position);
      if (position == length) return;
    }
    int state = this.state;
    while (position < length) {
      int char = getChar(position);
      switch (char) {
        case SPACE:
        case CARRIAGE_RETURN:
        case NEWLINE:
        case TAB:
          position++;
          break;
        case QUOTE:
          if ((state & ALLOW_STRING_MASK) != 0) fail(position);
          state |= VALUE_READ_BITS;
          position = parseString(position + 1);
          break;
        case LBRACKET:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          listener.beginArray();
          saveState(state);
          state = STATE_ARRAY_EMPTY;
          position++;
          break;
        case LBRACE:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          listener.beginObject();
          saveState(state);
          state = STATE_OBJECT_EMPTY;
          position++;
          break;
        case CHAR_n:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          state |= VALUE_READ_BITS;
          position = parseNull(position);
          break;
        case CHAR_f:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          state |= VALUE_READ_BITS;
          position = parseFalse(position);
          break;
        case CHAR_t:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          state |= VALUE_READ_BITS;
          position = parseTrue(position);
          break;
        case COLON:
          if (state != STATE_OBJECT_KEY) fail(position);
          listener.propertyName();
          state = STATE_OBJECT_COLON;
          position++;
          break;
        case COMMA:
          if (state == STATE_OBJECT_VALUE) {
            listener.propertyValue();
            state = STATE_OBJECT_COMMA;
            position++;
          } else if (state == STATE_ARRAY_VALUE) {
            listener.arrayElement();
            state = STATE_ARRAY_COMMA;
            position++;
          } else {
            fail(position);
          }
          break;
        case RBRACKET:
          if (state == STATE_ARRAY_EMPTY) {
            listener.endArray();
          } else if (state == STATE_ARRAY_VALUE) {
            listener.arrayElement();
            listener.endArray();
          } else {
            fail(position);
          }
          state = restoreState() | VALUE_READ_BITS;
          position++;
          break;
        case RBRACE:
          if (state == STATE_OBJECT_EMPTY) {
            listener.endObject();
          } else if (state == STATE_OBJECT_VALUE) {
            listener.propertyValue();
            listener.endObject();
          } else {
            fail(position);
          }
          state = restoreState() | VALUE_READ_BITS;
          position++;
          break;
        default:
          if ((state & ALLOW_VALUE_MASK) != 0) fail(position);
          state |= VALUE_READ_BITS;
          position = parseNumber(char, position);
          break;
      }
      if (state == STATE_END) {
        // Reset state
        state = STATE_INITIAL;
        // Reset stack
        listener.stack.clear();
        _sink?.add(listener.result);
      }
    }
    this.state = state;
  }

  /// Parses a "true" literal starting at [position].
  ///
  /// The character `source[position]` must be "t".
  int parseTrue(int position) {
    assert(getChar(position) == CHAR_t);
    if (chunkEnd < position + 4) {
      return parseKeywordPrefix(position, "true", KWD_TRUE);
    }
    if (getChar(position + 1) != CHAR_r ||
        getChar(position + 2) != CHAR_u ||
        getChar(position + 3) != CHAR_e) {
      fail(position);
    }
    listener.handleBool(true);
    return position + 4;
  }

  /// Parses a "false" literal starting at [position].
  ///
  /// The character `source[position]` must be "f".
  int parseFalse(int position) {
    assert(getChar(position) == CHAR_f);
    if (chunkEnd < position + 5) {
      return parseKeywordPrefix(position, "false", KWD_FALSE);
    }
    if (getChar(position + 1) != CHAR_a ||
        getChar(position + 2) != CHAR_l ||
        getChar(position + 3) != CHAR_s ||
        getChar(position + 4) != CHAR_e) {
      fail(position);
    }
    listener.handleBool(false);
    return position + 5;
  }

  /// Parses a "null" literal starting at [position].
  ///
  /// The character `source[position]` must be "n".
  int parseNull(int position) {
    assert(getChar(position) == CHAR_n);
    if (chunkEnd < position + 4) {
      return parseKeywordPrefix(position, "null", KWD_NULL);
    }
    if (getChar(position + 1) != CHAR_u ||
        getChar(position + 2) != CHAR_l ||
        getChar(position + 3) != CHAR_l) {
      fail(position);
    }
    listener.handleNull();
    return position + 4;
  }

  int parseKeywordPrefix(int position, String chars, int type) {
    assert(getChar(position) == chars.codeUnitAt(0));
    int length = chunkEnd;
    int start = position;
    int count = 1;
    while (++position < length) {
      int char = getChar(position);
      if (char != chars.codeUnitAt(count)) fail(start);
      count++;
    }
    partialState = PARTIAL_KEYWORD | type | (count << KWD_COUNT_SHIFT);
    return length;
  }

  /// Parses a string value.
  ///
  /// Initial [position] is right after the initial quote.
  /// Returned position right after the final quote.
  int parseString(int position) {
    // Format: '"'([^\x00-\x1f\\\"]|'\\'[bfnrt/\\"])*'"'
    // Initial position is right after first '"'.
    int start = position;
    int end = chunkEnd;
    int bits = 0;
    while (position < end) {
      int char = getChar(position++);
      bits |= char; // Includes final '"', but that never matters.
      // BACKSLASH is larger than QUOTE and SPACE.
      if (char > BACKSLASH) {
        continue;
      }
      if (char == BACKSLASH) {
        beginString();
        int sliceEnd = position - 1;
        if (start < sliceEnd) addSliceToString(start, sliceEnd);
        return parseStringToBuffer(sliceEnd);
      }
      if (char == QUOTE) {
        listener.handleString(getString(start, position - 1, bits));
        return position;
      }
      if (char < SPACE) {
        fail(position - 1, "Control character in string");
      }
    }
    beginString();
    if (start < end) addSliceToString(start, end);
    return chunkString(STR_PLAIN);
  }

  /// Sets up a partial string state.
  ///
  /// The state is either not inside an escape, or right after a backslash.
  /// For partial strings ending inside a Unicode escape, use
  /// [chunkStringEscapeU].
  int chunkString(int stringState) {
    partialState = PARTIAL_STRING | stringState;
    return chunkEnd;
  }

  /// Sets up a partial string state for a partially parsed Unicode escape.
  ///
  /// The partial string state includes the current [buffer] and the
  /// number of hex digits of the Unicode seen so far (e.g., for `"\u30')
  /// the state knows that two digits have been seen, and what their value is.
  ///
  /// Returns [chunkEnd] so it can be used as part of a return statement.
  int chunkStringEscapeU(int count, int value) {
    partialState = PARTIAL_STRING |
        STR_U |
        (count << STR_U_COUNT_SHIFT) |
        (value << STR_U_VALUE_SHIFT);
    return chunkEnd;
  }

  /// Parses the remainder of a string literal into a buffer.
  ///
  /// The buffer is stored in [buffer] and its underlying format depends on
  /// the input chunk type. For example UTF-8 decoding happens in the
  /// buffer, not in the parser, since all significant JSON characters are ASCII.
  ///
  /// This function scans through the string literal for escapes, and copies
  /// slices of non-escape characters using [addSliceToString].
  int parseStringToBuffer(int position) {
    int end = chunkEnd;
    int start = position;
    while (true) {
      if (position == end) {
        if (position > start) {
          addSliceToString(start, position);
        }
        return chunkString(STR_PLAIN);
      }
      int char = getChar(position++);
      if (char > BACKSLASH) continue;
      if (char < SPACE) {
        fail(position - 1); // Control character in string.
      }
      if (char == QUOTE) {
        int quotePosition = position - 1;
        if (quotePosition > start) {
          addSliceToString(start, quotePosition);
        }
        listener.handleString(endString());
        return position;
      }
      if (char != BACKSLASH) {
        continue;
      }
      // Handle escape.
      if (position - 1 > start) {
        addSliceToString(start, position - 1);
      }
      if (position == end) return chunkString(STR_ESCAPE);
      position = parseStringEscape(position);
      if (position == end) return position;
      start = position;
    }
    //return -1; // UNREACHABLE.
  }

  /// Parse a string escape.
  ///
  /// Position is right after the initial backslash.
  /// The following escape is parsed into a character code which is added to
  /// the current string buffer using [addCharToString].
  ///
  /// Returns position after the last character of the escape.
  int parseStringEscape(int position) {
    int char = getChar(position++);
    int length = chunkEnd;
    switch (char) {
      case CHAR_b:
        char = BACKSPACE;
        break;
      case CHAR_f:
        char = FORM_FEED;
        break;
      case CHAR_n:
        char = NEWLINE;
        break;
      case CHAR_r:
        char = CARRIAGE_RETURN;
        break;
      case CHAR_t:
        char = TAB;
        break;
      case SLASH:
      case BACKSLASH:
      case QUOTE:
        break;
      case CHAR_u:
        int hexStart = position - 1;
        int value = 0;
        for (int i = 0; i < 4; i++) {
          if (position == length) return chunkStringEscapeU(i, value);
          char = getChar(position++);
          int digit = char ^ 0x30;
          value *= 16;
          if (digit <= 9) {
            value += digit;
          } else {
            digit = (char | 0x20) - CHAR_a;
            if (digit < 0 || digit > 5) {
              fail(hexStart, "Invalid unicode escape");
            }
            value += digit + 10;
          }
        }
        char = value;
        break;
      default:
        if (char < SPACE) fail(position, "Control character in string");
        fail(position, "Unrecognized string escape");
    }
    addCharToString(char);
    if (position == length) return chunkString(STR_PLAIN);
    return position;
  }

  /// Sets up a partial numeral state.
  /// Returns chunkEnd to allow easy one-line bailout tests.
  int beginChunkNumber(int state, int start) {
    int end = chunkEnd;
    int length = end - start;
    var buffer = _NumberBuffer(length);
    copyCharsToList(start, end, buffer.list, 0);
    buffer.length = length;
    this.buffer = buffer;
    partialState = PARTIAL_NUMERAL | state;
    return end;
  }

  void addNumberChunk(_NumberBuffer buffer, int start, int end, int overhead) {
    int length = end - start;
    int count = buffer.length;
    int newCount = count + length;
    int newCapacity = newCount + overhead;
    buffer.ensureCapacity(newCapacity);
    copyCharsToList(start, end, buffer.list, count);
    buffer.length = newCount;
  }

  // Continues an already chunked number across an entire chunk.
  int continueChunkNumber(int state, int start, _NumberBuffer buffer) {
    int end = chunkEnd;
    addNumberChunk(buffer, start, end, _NumberBuffer.defaultOverhead);
    this.buffer = buffer;
    partialState = PARTIAL_NUMERAL | state;
    return end;
  }

  int finishChunkNumber(int state, int start, int end, _NumberBuffer buffer) {
    if (state == NUM_ZERO) {
      listener.handleNumber(0);
      return end;
    }
    if (end > start) {
      addNumberChunk(buffer, start, end, 0);
    }
    if (state == NUM_DIGIT) {
      num value = buffer.parseNum();
      listener.handleNumber(value);
    } else if (state == NUM_DOT_DIGIT || state == NUM_E_DIGIT) {
      listener.handleNumber(buffer.parseDouble());
    } else {
      fail(chunkEnd, "Unterminated number literal");
    }
    return end;
  }

  int parseNumber(int char, int position) {
    // Also called on any unexpected character.
    // Format:
    //  '-'?('0'|[1-9][0-9]*)('.'[0-9]+)?([eE][+-]?[0-9]+)?
    int start = position;
    int length = chunkEnd;
    // Collects an int value while parsing. Used for both an integer literal,
    // and the exponent part of a double literal.
    // Stored as negative to ensure we can represent -2^63.
    int intValue = 0;
    double doubleValue = 0.0; // Collect double value while parsing.
    // 1 if there is no leading -, -1 if there is.
    int sign = 1;
    bool isDouble = false;
    // Break this block when the end of the number literal is reached.
    // At that time, position points to the next character, and isDouble
    // is set if the literal contains a decimal point or an exponential.
    if (char == MINUS) {
      sign = -1;
      position++;
      if (position == length) return beginChunkNumber(NUM_SIGN, start);
      char = getChar(position);
    }
    int digit = char ^ CHAR_0;
    if (digit > 9) {
      if (sign < 0) {
        fail(position, "Missing expected digit");
      } else {
        // If it doesn't even start out as a numeral.
        fail(position);
      }
    }
    if (digit == 0) {
      position++;
      if (position == length) return beginChunkNumber(NUM_ZERO, start);
      char = getChar(position);
      digit = char ^ CHAR_0;
      // If starting with zero, next character must not be digit.
      if (digit <= 9) fail(position);
    } else {
      int digitCount = 0;
      do {
        if (digitCount >= 18) {
          // Check for overflow.
          // Is 1 if digit is 8 or 9 and sign == 0, or digit is 9 and sign < 0;
          int highDigit = digit >> 3;
          if (sign < 0) highDigit &= digit;
          /* chrome:  https://github.com/moontreeapp/moontree/issues/372
          : Error: The integer literal 922337203685477580 can't be represented 
            exactly in JavaScript.
          ../…/client/json_newline_transformer.dart:1371
          Try changing the literal to something that can be represented in
            Javascript. In Javascript 922337203685477632 is the nearest value
            that can be represented exactly.
          if (digitCount == 19 || intValue - highDigit < -922337203685477580) {
                                                          ^^^^^^^^^^^^^^^^^^
          Failed to compile application.
          */
          if (digitCount == 19 || intValue - highDigit < -922337203685477580) {
            isDouble = true;
            // Big value that we know is not trusted to be exact later,
            // forcing reparsing using `double.parse`.
            doubleValue = 9223372036854775808.0;
          }
        }
        intValue = 10 * intValue - digit;
        digitCount++;
        position++;
        if (position == length) return beginChunkNumber(NUM_DIGIT, start);
        char = getChar(position);
        digit = char ^ CHAR_0;
      } while (digit <= 9);
    }
    if (char == DECIMALPOINT) {
      if (!isDouble) {
        isDouble = true;
        doubleValue = (intValue == 0) ? 0.0 : -intValue.toDouble();
      }
      intValue = 0;
      position++;
      if (position == length) return beginChunkNumber(NUM_DOT, start);
      char = getChar(position);
      digit = char ^ CHAR_0;
      if (digit > 9) fail(position);
      do {
        doubleValue = 10.0 * doubleValue + digit;
        intValue -= 1;
        position++;
        if (position == length) return beginChunkNumber(NUM_DOT_DIGIT, start);
        char = getChar(position);
        digit = char ^ CHAR_0;
      } while (digit <= 9);
    }
    if ((char | 0x20) == CHAR_e) {
      if (!isDouble) {
        isDouble = true;
        doubleValue = (intValue == 0) ? 0.0 : -intValue.toDouble();
        intValue = 0;
      }
      position++;
      if (position == length) return beginChunkNumber(NUM_E, start);
      char = getChar(position);
      int expSign = 1;
      int exponent = 0;
      if (((char + 1) | 2) == 0x2e /*+ or -*/) {
        expSign = 0x2C - char; // -1 for MINUS, +1 for PLUS
        position++;
        if (position == length) return beginChunkNumber(NUM_E_SIGN, start);
        char = getChar(position);
      }
      digit = char ^ CHAR_0;
      if (digit > 9) {
        fail(position, "Missing expected digit");
      }
      bool exponentOverflow = false;
      do {
        exponent = 10 * exponent + digit;
        if (exponent > 400) exponentOverflow = true;
        position++;
        if (position == length) return beginChunkNumber(NUM_E_DIGIT, start);
        char = getChar(position);
        digit = char ^ CHAR_0;
      } while (digit <= 9);
      if (exponentOverflow) {
        if (doubleValue == 0.0 || expSign < 0) {
          listener.handleNumber(sign < 0 ? -0.0 : 0.0);
        } else {
          listener.handleNumber(
              sign < 0 ? double.negativeInfinity : double.infinity);
        }
        return position;
      }
      intValue += expSign * exponent;
    }
    if (!isDouble) {
      int bitFlag = -(sign + 1) >> 1; // 0 if sign == -1, -1 if sign == 1
      // Negate if bitFlag is -1 by doing ~intValue + 1
      listener.handleNumber((intValue ^ bitFlag) - bitFlag);
      return position;
    }
    // Double values at or above this value (2 ** 53) may have lost precision.
    // Only trust results that are below this value.
    const double maxExactDouble = 9007199254740992.0;
    if (doubleValue < maxExactDouble) {
      int exponent = intValue;
      double signedMantissa = doubleValue * sign;
      if (exponent >= -22) {
        if (exponent < 0) {
          listener.handleNumber(signedMantissa / powersOfTen[-exponent]);
          return position;
        }
        if (exponent == 0) {
          listener.handleNumber(signedMantissa);
          return position;
        }
        if (exponent <= 22) {
          listener.handleNumber(signedMantissa * powersOfTen[exponent]);
          return position;
        }
      }
    }
    // If the value is outside the range +/-maxExactDouble or
    // exponent is outside the range +/-22, then we can't trust simple double
    // arithmetic to get the exact result, so we use the system double parsing.
    listener.handleNumber(parseDouble(start, position));
    return position;
  }

  Never fail(int position, [String? message]) {
    if (message == null) {
      message = "Unexpected character";
      if (position == chunkEnd) message = "Unexpected end of input";
    }
    throw FormatException(message, chunk, position);
  }
}

/// Chunked JSON parser that parses [String] chunks.
class _JsonStringParser extends _ChunkedJsonParser<String> {
  @override
  String chunk = '';
  @override
  int chunkEnd = 0;

  _JsonStringParser(_JsonListener listener, Sink<Object?>? sink)
      : super(listener, sink);

  @override
  int getChar(int position) => chunk.codeUnitAt(position);

  @override
  String getString(int start, int end, int bits) {
    return chunk.substring(start, end);
  }

  @override
  void beginString() {
    buffer = StringBuffer();
  }

  @override
  void addSliceToString(int start, int end) {
    StringBuffer buffer = this.buffer;
    buffer.write(chunk.substring(start, end));
  }

  @override
  void addCharToString(int charCode) {
    StringBuffer buffer = this.buffer;
    buffer.writeCharCode(charCode);
  }

  @override
  String endString() {
    StringBuffer buffer = this.buffer;
    this.buffer = null;
    return buffer.toString();
  }

  @override
  void copyCharsToList(int start, int end, List target, int offset) {
    int length = end - start;
    for (int i = 0; i < length; i++) {
      target[offset + i] = chunk.codeUnitAt(start + i);
    }
  }

  @override
  double parseDouble(int start, int end) {
    double? d = _parseDouble(chunk, start, end);
    if (d == null) {
      throw "Invalid double";
    }
    return d;
  }
}

/// Implements the chunked conversion from a JSON string to its corresponding
/// object.
///
/// The sink only creates one object, but its input can be chunked.
class _JsonStringDecoderSink extends StringConversionSinkBase {
  final _JsonStringParser _parser;
  final Object? Function(Object? key, Object? value)? _reviver;
  final Sink<Object?> _sink;

  _JsonStringDecoderSink(this._reviver, this._sink)
      : _parser = _createParser(_reviver, _sink);

  static _JsonStringParser _createParser(
      Object? Function(Object? key, Object? value)? reviver,
      Sink<Object?> sink) {
    _BuildJsonListener listener;
    if (reviver == null) {
      listener = _BuildJsonListener();
    } else {
      listener = _ReviverJsonListener(reviver);
    }
    return _JsonStringParser(listener, sink);
  }

  @override
  void addSlice(String chunk, int start, int end, bool isLast) {
    _parser.chunk = chunk;
    _parser.chunkEnd = end;
    _parser.parse(start);
    if (isLast) _parser.close();
  }

  @override
  void add(String chunk) {
    addSlice(chunk, 0, chunk.length, false);
  }

  @override
  void close() {
    _parser.close();
    _sink.close();
  }

  @override
  ByteConversionSink asUtf8Sink(bool allowMalformed) {
    throw "Unimplemented";
  }
}

double? _parseDouble(String str, int start, int end) {
  assert(start < end);
  const int _DOT = 0x2e; // '.'
  const int _ZERO = 0x30; // '0'
  const int _MINUS = 0x2d; // '-'
  const int _N = 0x4e; // 'N'
  const int _a = 0x61; // 'a'
  const int _I = 0x49; // 'I'
  const int _e = 0x65; // 'e'
  int exponent = 0;
  // Set to non-zero if a digit is seen. Avoids accepting ".".
  bool digitsSeen = false;
  // Added to exponent for each digit. Set to -1 when seeing '.'.
  int exponentDelta = 0;
  double doubleValue = 0.0;
  double sign = 1.0;
  int firstChar = str.codeUnitAt(start);
  if (firstChar == _MINUS) {
    sign = -1.0;
    start++;
    if (start == end) return null;
    firstChar = str.codeUnitAt(start);
  }
  if (firstChar == _I) {
    if (end == start + 8 && str.startsWith("nfinity", start + 1)) {
      return sign * double.infinity;
    }
    return null;
  }
  if (firstChar == _N) {
    if (end == start + 3 &&
        str.codeUnitAt(start + 1) == _a &&
        str.codeUnitAt(start + 2) == _N) {
      return double.nan;
    }
    return null;
  }

  int firstDigit = firstChar ^ _ZERO;
  if (firstDigit <= 9) {
    start++;
    doubleValue = firstDigit.toDouble();
    digitsSeen = true;
  }
  for (int i = start; i < end; i++) {
    int c = str.codeUnitAt(i);
    int digit = c ^ _ZERO; // '0'-'9' characters are now 0-9 integers.
    if (digit <= 9) {
      doubleValue = 10.0 * doubleValue + digit;
      // Doubles at or above this value (2**53) might have lost precission.
      const double MAX_EXACT_DOUBLE = 9007199254740992.0;
      if (doubleValue >= MAX_EXACT_DOUBLE) return null;
      exponent += exponentDelta;
      digitsSeen = true;
    } else if (c == _DOT && exponentDelta == 0) {
      exponentDelta = -1;
    } else if ((c | 0x20) == _e) {
      i++;
      if (i == end) return null;
      // int._tryParseSmi treats its end argument as inclusive.
      final int? expPart = _tryParseSmi(str, i, end - 1);
      if (expPart == null) return null;
      exponent += expPart;
      break;
    } else {
      return null;
    }
  }
  if (!digitsSeen) return null; // No digits.
  if (exponent == 0) return sign * doubleValue;
  const P10 = powersOfTen; // From shared library
  if (exponent < 0) {
    int negExponent = -exponent;
    if (negExponent >= P10.length) return null;
    return sign * (doubleValue / P10[negExponent]);
  }
  if (exponent >= P10.length) return null;
  return sign * (doubleValue * P10[exponent]);
}

int? _tryParseSmi(String str, int first, int last) {
  assert(first <= last);
  var ix = first;
  var sign = 1;
  var c = str.codeUnitAt(ix);
  // Check for leading '+' or '-'.
  if ((c == 0x2b) || (c == 0x2d)) {
    ix++;
    sign = 0x2c - c; // -1 for '-', +1 for '+'.
    if (ix > last) {
      return null; // Empty.
    }
  }
  //var smiLimit = has63BitSmis ? 18 : 9;
  // Default to smallest
  var smiLimit = 9;
  if ((last - ix) >= smiLimit) {
    return null; // May not fit into a Smi.
  }
  var result = 0;
  for (int i = ix; i <= last; i++) {
    var c = 0x30 ^ str.codeUnitAt(i);
    if (9 < c) {
      return null;
    }
    result = 10 * result + c;
  }
  return sign * result;
}
