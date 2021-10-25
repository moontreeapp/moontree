/// http://www.refactord.com/guides/backup-restore-share-json-file-flutter

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class Storage {
  Future<Directory> get _localDir async =>
      await getApplicationDocumentsDirectory();

  Future<String> get _localPath async => (await _localDir).path;

  Future<File> _localFile(String filename, {String? path}) async =>
      File('${path ?? await _localPath}/$filename.json');

  Future<File> writeExport({
    required String filename,
    Map<String, dynamic>? export,
    String? rawExport,
  }) async {
    rawExport = rawExport ?? jsonEncode(export);
    if (!await Permission.storage.request().isGranted) {
      return Future.value(null);
    }
    final file = await _localFile(filename);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file.writeAsString(rawExport);
  }

  void share(String filepath) async =>
      Share.shareFiles([filepath], text: 'Ravencoin Backup');

  Future<Map<String, dynamic>> readExport({
    File? file,
    String? filename,
    String? path,
  }) async {
    file = file ?? await _localFile(filename!, path: path);
    try {
      return json.decode(await file.readAsString());
    } catch (e) {
      return {};
    }
  }

  Future<String> readExportRaw({
    File? file,
    String? filename,
    String? path,
  }) async {
    file = file ?? await _localFile(filename!, path: path);
    try {
      return await file.readAsString();
    } catch (e) {
      return '';
    }
  }

  Future<Map<String, dynamic>?> readFromFilePicker() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      // file not found?
      return null;
    }
    //return await readExport(
    //    path: result.files[0].path, filename: result.files[0].name);
    return await readExport(file: File(result.files.single.path!));
  }

  Future<String?> readFromFilePickerRaw() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      return null;
    }
    return await readExportRaw(file: File(result.files.single.path!));
  }

  Future<List<FileSystemEntity>> listDir([String? path]) async =>
      await (path != null ? Directory(path) : await _localDir).list().toList();
}
