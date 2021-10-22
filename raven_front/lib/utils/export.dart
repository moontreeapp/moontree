import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class Storage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    var path = directory.path;
    return path;
  }

  Future<File> _localFile(String filename) async {
    final path = await _localPath;
    return File('$path/$filename.json');
  }

  Future<File> writeExport(
      {required String filename, required Map<String, dynamic> export}) async {
    if (!await Permission.storage.request().isGranted) {
      return Future.value(null);
    }
    final file = await _localFile(filename);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file.writeAsString(jsonEncode(export));
  }

  void share(String filepath) async {
    Share.shareFiles([filepath], text: 'Ravencoin Backup');
  }
}
// http://www.refactord.com/guides/backup-restore-share-json-file-flutter