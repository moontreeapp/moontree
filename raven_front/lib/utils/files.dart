// https://flutter.dev/docs/cookbook/persistence/reading-writing-files#complete-example

import 'dart:io';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

/// '/data/user/0/com.example.raven_mobile/app_flutter'
Future<String> get _localDocumentsPath async =>
    (await getApplicationDocumentsDirectory()).path;

Future<File> _localFile(String filename) async => File(
    '${await _localDocumentsPath}/raven-mobile/$filename.json')
  // read-only issues
  //File(
  //'content://com.android.providers.downloads.documents/document/downloads/raven-mobile/$filename.json')
  //'/com.android.externalstorage.documents/document/primary%3ADownload/raven-mobile/$filename.json')
  //'/document/downloads/raven-mobile/$filename.json')
  ..createSync(recursive: true);

Future<File> writeToExport(
    {required String filename, required Map<String, dynamic> json}) async {
  //print(await _localFile(filename));
  //print(jsonEncode(json));
  return (await _localFile(filename)).writeAsString(jsonEncode(json));
}

Future<Map<String, dynamic>> readExportedFile(
    {required String filename}) async {
  try {
    var file = await _localFile(filename);
    var contents = await file.readAsString();
    Map<String, dynamic> importAccount = jsonDecode(contents);
    return importAccount;
  } catch (e) {
    // If encountering an error, return 0
    return {};
  }
}

// Directory('foo').createSync()
// File('path/to/file').createSync(recursive: true);