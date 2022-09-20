/// http://www.refactord.com/guides/backup-restore-share-json-file-flutter

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:ravencoin_back/utilities/random.dart';
import 'package:share/share.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Storage {
  Future<Directory> get _localDir async =>
      await getApplicationDocumentsDirectory();

  Future<String> get localPath async => (await _localDir).path;

  Future<File> _localFile(String filename,
          {String? path, String extension = 'json'}) async =>
      File('${path ?? await localPath}/$filename.$extension');

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
  Future<File?> writeExport({
    required String filename,
    Map<String, dynamic>? export,
    String? rawExport,
  }) async {
    rawExport = rawExport ?? jsonEncode(export);
    if (!await Permission.storage.request().isGranted) {
      // ignore: null_argument_to_non_null_type
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

  Future<FileDetails?> readExportSize({
    File? file,
    String? filename,
    String? path,
  }) async {
    file = file ?? await _localFile(filename!, path: path);
    var size = file.lengthSync() / 1024;
    try {
      //try {
      //  var content = file.readAsStringSync();
      //  return FileDetails(
      //      filename: filename ?? 'unknown filename',
      //      content: content,
      //      size: size);
      //} catch (e) {
      var contentBytes = await file.readAsBytes();
      return FileDetails(
          filename: filename ?? file.path.split('/').last,
          contentBytes: contentBytes,
          size: size);
      //}
    } catch (e) {
      return FileDetails(
          filename: 'Unable to Read File', content: 'unknown', size: size);
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

  Future<FileDetails?> readFromFilePickerSize() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) {
      // file not found?
      return null;
    }
    //return await readExport(
    //    path: result.files[0].path, filename: result.files[0].name);
    return await readExportSize(file: File(result.files.single.path!));
  }
}

class AssetLogos extends Storage {
  @override
  Future<File> _localFile(String filename,
          {String extension = 'png', String? path}) async =>
      File('${path ?? await localPath}/images/$filename');

  //File _localFileNow(String filename, String path) =>
  //    File('$path/images/$filename');

  /// writes the logo by its ipfs hash as filename
  Future<File> writeLogo({
    required String filename,
    required Uint8List bytes,
  }) async {
    if (!await Permission.storage.request().isGranted) {
      // ignore: null_argument_to_non_null_type
      return Future.value(null);
    }

    return (await _verifyLocalFile(await _localFile(filename)))
      ..writeAsBytesSync(bytes);
  }

  /// usecase:
  /// Image.memory(storage.readLogo(ipfsHash))
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

  /// usecase:
  /// Image.file(await storage.readLogoFile(ipfsHash))
  Future<File?> readLogoFile(String filename,
      {bool returnEmptyFile = false}) async {
    var file = await _localFile(filename);
    if (!await file.exists()) {
      return file;
    }
    if (returnEmptyFile) {
      return file;
    }
    return null;
  }

  /// usecase:
  /// Image.file(storage.readLogoFile(ipfsHash))
  File readImageFileNow(String path) =>
      //_localFileNow(filename, path);
      //_localFileNowPath(filePath);
      File(path);
}

class FileDetails {
  final String filename;
  final Uint8List? contentBytes;
  final String? content;
  final double size;

  FileDetails(
      {required this.filename,
      required this.size,
      this.content,
      this.contentBytes});
}

class SecureStorage {
  Future example() async {
    final key = 'key';
    // Create storage
    final storage = new FlutterSecureStorage();
    // Read value
    String? value = await storage.read(key: key);
    // Read all values
    Map<String, String> allValues = await storage.readAll();
    // Write value
    await storage.write(key: key, value: value);
    // Delete value
    await storage.delete(key: key);
    // Delete all
    await storage.deleteAll();
  }

  static Future<String> get authenticationKey async {
    const key = 'authenticationKey';
    final storage = FlutterSecureStorage();
    String? value = await storage.read(key: key);
    if (value != null) {
      return value;
    }
    final bioKey = randomString();
    await storage.write(key: key, value: bioKey);
    return bioKey;
  }

  static Future writeSecret(Secret? secret) async {
    if (secret == null) return;
    final storage = FlutterSecureStorage();
    await storage.write(
      key: secret.pubkey ?? secret.scripthash!, value: secret.secret,
      //iOptions:IOSOptions(),
      //aOptions: AndroidOptions(),
    );
  }

  static Future<String?> readSecret(Secret secret) async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: secret.pubkey ?? secret.scripthash!);
  }

  static Future<String?> read(String key) async {
    final storage = FlutterSecureStorage();
    return await storage.read(key: key);
  }
}
