import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:raven/utils/exceptions.dart';
import 'package:raven/utils/extensions.dart';
import 'package:raven_mobile/services/storage.dart';

class MetadataGrabber {
  late String? ipfsHash;
  String? logo;
  Map<dynamic, dynamic> json = {};
  bool ableToInterpret = false;

  MetadataGrabber([this.ipfsHash]);

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
    var response = await _call();
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

  Future<http.Response> _call() async =>
      await http.get(Uri.parse('https://gateway.ipfs.io/ipfs/$ipfsHash'),
          headers: {'accept': 'application/json'});

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
    MetadataGrabber(logo).get();
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
