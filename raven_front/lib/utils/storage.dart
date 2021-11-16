/// http://www.refactord.com/guides/backup-restore-share-json-file-flutter

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class Storage {
  Future<Directory> get _localDir async =>
      await getApplicationDocumentsDirectory();

  Future<String> get _localPath async => (await _localDir).path;

  Future<File> _localFile(String filename,
          {String? path, String extension = 'json'}) async =>
      File('${path ?? await _localPath}/$filename.$extension');

  Future<File> _verifyLocalFile(File file) async {
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    return file;
  }

  Future<List<FileSystemEntity>> listDir([String? path]) async =>
      await (path != null ? Directory(path) : await _localDir).list().toList();
}

class Backup extends Storage {
  Future<File> writeExport({
    required String filename,
    Map<String, dynamic>? export,
    String? rawExport,
  }) async {
    rawExport = rawExport ?? jsonEncode(export);
    if (!await Permission.storage.request().isGranted) {
      return Future.value(null);
    }
    return (await _verifyLocalFile(await _localFile(filename)))
      ..writeAsString(rawExport);
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
}

class AssetLogos extends Storage {
  @override
  Future<File> _localFile(String filename,
          {String extension = 'png', String? path}) async =>
      File('${await _localPath}/images/$filename');

  /// writes the logo by its ipfs hash as filename
  Future<File> writeLogo({
    required String filename,
    required Uint8List bytes,
  }) async {
    if (!await Permission.storage.request().isGranted) {
      return Future.value(null);
    }

    return (await _verifyLocalFile(await _localFile(filename)))
      ..writeAsBytesSync(bytes);
  }

  Future<Uint8List?> readLogo({
    File? file,
    String? filename,
  }) async {
    file = file ?? await _localFile(filename!);
    try {
      return await file.readAsBytes();
    } catch (e) {
      return null;
    }
  }
}
