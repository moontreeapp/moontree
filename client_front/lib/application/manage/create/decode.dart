import 'package:multibase/multibase.dart';
import 'package:multicodec/multicodec.dart';
import 'package:dart_multihash/dart_multihash.dart';
import 'package:base58/base58.dart';

class BaseCID {
  late int _version;
  late String _codec;
  late List<int> _multihash;

  BaseCID(int version, String codec, List<int> multihash) {
    _version = version;
    _codec = codec;
    _multihash = multihash;
  }

  int get version => _version;

  String get codec => _codec;

  List<int> get multihash => _multihash;

  List<int> get buffer {
    throw UnimplementedError();
  }

  String encode() {
    throw UnimplementedError();
  }

  @override
  String toString() {
    String truncate(List<int> data, int length) {
      if (data.length > length) {
        return data.sublist(0, length).toString() + '..';
      } else {
        return data.toString();
      }
    }

    final truncateLength = 20;
    return '${this.runtimeType}(version: $_version, codec: $_codec, multihash: ${truncate(_multihash, truncateLength)})';
  }

  @override
  bool operator ==(other) {
    return (other is BaseCID) &&
        (_version == other.version) &&
        (_codec == other.codec) &&
        (_multihash == other.multihash);
  }
}

class CIDv0 extends BaseCID {
  static const String CODEC = 'dag-pb';

  CIDv0(List<int> multihash) : super(0, CODEC, multihash);

  @override
  List<int> get buffer => multihash;

  @override
  String encode() {
    return Base58Encoder().convert(buffer);
  }

  CIDv1 toV1() {
    return CIDv1(_codec, _multihash);
  }
}

class CIDv1 extends BaseCID {
  CIDv1(String codec, List<int> multihash) : super(1, codec, multihash);

  @override
  List<int> get buffer {
    final data = _version.toBytes() + multicodec.addPrefix(_codec, _multihash);
    return List<int>.from(data);
  }

  String encode({String encoding = 'base58btc'}) {
    return MultibaseCodec(encoding).encode(buffer);
  }

  CIDv0 toV0() {
    if (_codec != CIDv0.CODEC) {
      throw ArgumentError(
          'CIDv1 can only be converted for codec ${CIDv0.CODEC}');
    }
    return CIDv0(_multihash);
  }
}

BaseCID makeCID(dynamic arg1, [dynamic arg2, dynamic arg3]) {
  if (arg3 != null) {
    final version = arg1 as int;
    final codec = arg2 as String;
    final multihash = arg3 as List<int>;

    if (version != 0 && version != 1) {
      throw ArgumentError('Version should be 0 or 1, $version was provided');
    }

    if (!Multicodec.isCodec(codec)) {
      throw ArgumentError('Invalid codec $codec provided, please check');
    }

    if (!(multihash is String) && !(multihash is List<int>)) {
      throw ArgumentError(
          'Invalid type for multihash provided, should be String or List<int>');
    }

    if (version == 0) {
      if (codec != CIDv0.CODEC) {
        throw ArgumentError(
            'Codec for version 0 can only be ${CIDv0.CODEC}, found: $codec');
      }
      return CIDv0(multihash as List<int>);
    } else {
      return CIDv1(codec, multihash as List<int>);
    }
  } else if (arg2 != null) {
    final data = arg1 as dynamic;

    if (data is String) {
      return fromString(data);
    } else if (data is List<int>) {
      return fromBytes(data);
    } else {
      throw ArgumentError(
          'Invalid argument passed, expected: String or List<int>, found: ${data.runtimeType}');
    }
  } else {
    throw ArgumentError('Invalid number of arguments, expected 1 or 3');
  }
}

bool isCID(dynamic cidStr) {
  try {
    makeCID(cidStr);
    return true;
  } catch (e) {
    return false;
  }
}

BaseCID fromString(String cidStr) {
  final cidBytes = cidStr.codeUnits;
  return fromBytes(cidBytes);
}

BaseCID fromBytes(List<int> cidBytes) {
  if (cidBytes.length < 2) {
    throw ArgumentError('Argument length cannot be zero');
  }

  if (cidBytes[0] != 0 && Multibase.isEncoded(cidBytes)) {
    final cid = MultibaseDecoder().convert(cidBytes);
    if (cid.length < 2) {
      throw ArgumentError('CID length is invalid');
    }

    final data = cid.sublist(1);
    final version = int.parse(cid[0].toString());
    final codec = Multicodec.getCodec(data);
    final multihash = multicodec.removePrefix(data);
    return makeCID(version, codec, multihash);
  } else if (cidBytes[0] == 0 || cidBytes[0] == 1) {
    final version = cidBytes[0];
    final data = cidBytes.sublist(1);
    final codec = Multicodec.getCodec(data);
    final multihash = multicodec.removePrefix(data);
    return makeCID(version, codec, multihash);
  } else {
    try {
      final version = 0;
      final codec = CIDv0.CODEC;
      final multihash = Base58Decoder().convert(cidBytes);
      return CIDv0(multihash);
    } catch (e) {
      throw ArgumentError('Multihash is not a valid base58 encoded multihash');
    }
  }
}
