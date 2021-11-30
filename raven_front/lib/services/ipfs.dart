import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/utils/exceptions.dart';
import 'package:raven_back/utils/extensions.dart';
import 'package:raven_front/services/storage.dart';

class LogoGetter extends IpfsCall {
  String? logo;
  Map<dynamic, dynamic> json = {};
  bool ableToInterpret = false;

  LogoGetter([ipfsHash]) : super(ipfsHash);

  /// given a hash get the logo and other metadata set it on object
  /// return true if able to interpret data
  /// return false if unable to interpret data
  Future<bool> get([String? givenIpfsHash]) async {
    ipfsHash = givenIpfsHash ?? ipfsHash;
    try {
      return await _getMetadata();
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> _getMetadata() async {
    var response = await callIpfs();
    var jsonBody;
    if (_verify(response)) {
      jsonBody = _detectJson(response);
      if (jsonBody is Map<dynamic, dynamic>) {
        return _interpret(jsonBody);
      } else {
        return await _interpretAsImage(response.bodyBytes);
      }
    }
    return false;
  }

  bool _verify(http.Response response) =>
      response.statusCode == 200 ? true : false;

  Map<dynamic, dynamic>? _detectJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  /* what formats will we support? example:
  {
   "name": "NFT",
   "description": "This image shows the true nature of NFT.",
   "image": "https://ipfs.io/ipfs/QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr"
  }
  */
  bool _interpret(Map jsonBody) {
    String? imgString;
    var keyName = '';
    for (var kn in ['logo', 'icon', 'image']) {
      if (jsonBody.keys.contains(kn)) {
        keyName = kn;
        imgString = jsonBody[kn];
        break;
      }
    }
    if (keyName == '' || imgString == null) {
      throw BadResponseException('unable to interpret json data');
      //return false;
    }
    if (!(jsonBody[keyName] is String)) {
      throw BadResponseException('unable to interpret json data');
      //return false;
    }
    // is it url, hash?
    //"https://ipfs.io/ipfs/QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr"
    imgString = imgString.trimPattern('/');
    if (imgString.contains('/')) {
      imgString = imgString.split('/').last;
    }
    //} else if (raw binary image possibility) {
    //  imgString = interpretAsImage(jsonBody['logo'] ... as bytes)
    json = jsonBody;
    logo = imgString;
    // go save icon to device
    LogoGetter(logo).get();
    return true;
  }

  /// save bytes return path
  Future<bool> _interpretAsImage(Uint8List bytes,
      {String? givenIpfsHash}) async {
    AssetLogos storage = AssetLogos();
    var path = (await storage.writeLogo(
      filename: givenIpfsHash ?? logo ?? ipfsHash!,
      bytes: bytes,
    ))
        .absolute
        .path;
    return true;
    //return path;
  }
}

class IpfsMiniExplorer extends IpfsCall {
  MetadataType kind = MetadataType.Unknown;

  IpfsMiniExplorer([ipfsHash]) : super(ipfsHash);

  /// returns string: json or path of image or null
  Future<String?> get([String? givenIpfsHash]) async {
    ipfsHash = givenIpfsHash ?? ipfsHash;
    try {
      return await _getMetadata();
    } catch (e) {
      print(e);
    }
  }

  Future<String?> _getMetadata() async {
    var response = await callIpfs();
    var jsonBody;
    if (_verify(response)) {
      jsonBody = _detectJson(response);
      if (jsonBody is Map<dynamic, dynamic>) {
        kind = MetadataType.JsonString;
        return response.body; //jsonBody.toString();
      } else {
        kind = MetadataType.ImagePath;
        return await _saveImage(response.bodyBytes);
      }
    }
  }

  bool _verify(http.Response response) =>
      response.statusCode == 200 ? true : false;

  Map<dynamic, dynamic>? _detectJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      return null;
    }
  }

  Future<String?> _saveImage(Uint8List bytes, {String? givenIpfsHash}) async {
    try {
      return (await AssetLogos().writeLogo(
        filename: givenIpfsHash ?? ipfsHash!,
        bytes: bytes,
      ))
          .absolute
          .path;
    } catch (e) {
      kind = MetadataType.Unknown;
      print(e);
      // unable to save (perhaps bytes wasn't an image)
    }
  }
}

class IpfsCall {
  late String? ipfsHash;
  late String? url;

  IpfsCall([this.ipfsHash = '', this.url = 'https://gateway.ipfs.io/ipfs/']);

  Future<http.Response> callIpfs({
    String? givenHash,
    String? givenUrl,
  }) async =>
      await http.get(
        Uri.parse('${givenUrl ?? url}${givenHash ?? ipfsHash}'),
        headers: {'accept': 'application/json'},
      );

  /// returns the hash of a logo if one is explicitly sepcified
  static String? searchJsonForLogo({Map? jsonMap, String? jsonString}) {
    var logo;
    jsonMap = jsonMap ?? jsonDecode(jsonString ?? '{}');
    for (var key in ['logo', 'icon', 'image']) {
      if (jsonMap!.keys.contains(key)) {
        logo = jsonMap[key];
        break;
      }
    }
    if (logo is String) {
      // if url trim to hash
      // 'https://ipfs.io/ipfs/QmUnMkaEB5FBMDhjPsEtLyHr4ShSAoHUrwqVryCeuMosNr'
      logo = logo.trimPattern('/');
      if (logo.contains('/')) {
        logo = logo.split('/').last;
      }
      return logo;
    }
  }

  static bool isIpfs(String hash) => hash.contains(
      RegExp(r'Qm[1-9A-HJ-NP-Za-km-z]{44,}|b[A-Za-z2-7]{58,}|B[A-Z2-7]{58,}'
          '|z[1-9A-HJ-NP-Za-km-z]{48,}|F[0-9A-F]{50,}'));

  static Set<String> extractIpfsHashes(String content) => content
      .replaceAll('"', '')
      .replaceAll('}', '')
      .replaceAll(',', '')
      .split(' ')
      .where((hash) => isIpfs(hash))
      .toSet();
}
