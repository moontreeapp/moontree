import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:raven/utils/exceptions.dart';
import 'package:raven_mobile/services/storage.dart';

class MetadataGrabber {
  late String? ipfsHash;
  String icon = '';
  Map<dynamic, dynamic> json = {};
  bool ableToInterpret = false;

  MetadataGrabber([this.ipfsHash]);

  /// given a hash get the icon and other metadata set it on object
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
    var imgString;
    if (jsonBody['image'] is String) {
      if (jsonBody.keys.contains('image')) {
        imgString = jsonBody['image'];
      } else if (jsonBody.keys.contains('icon')) {
        imgString = jsonBody['icon'];
      } else if (jsonBody.keys.contains('logo')) {
        imgString = jsonBody['logo'];
      } else {
        throw BadResponseException('unable to interpret json data');
        //return false;
      }
    } else {
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
    icon = imgString;
    // go save icon to device
    return true;
  }

  /// save bytes return path
  Future<bool> _interpretAsImage(Uint8List bytes,
      {String? givenIpfsHash}) async {
    AssetLogos storage = AssetLogos();
    //save this path :
    (await storage.writeLogo(
            filename: givenIpfsHash ?? ipfsHash!, bytes: bytes))
        .absolute
        .path;
    return true;
  }
}
