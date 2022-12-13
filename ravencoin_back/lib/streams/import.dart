import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:rxdart/rxdart.dart';
import 'package:moontree_utils/moontree_utils.dart'
    show ReadableIdentifierExtension;

class Import {
  final BehaviorSubject<ImportRequest?> attempt =
      BehaviorSubject<ImportRequest?>.seeded(null)..name = 'import.attempt';
  final BehaviorSubject<ImportRequest?> result =
      BehaviorSubject<ImportRequest?>.seeded(null)..name = 'import.result';
  // ignore: prefer_void_to_null
  final PublishSubject<Null> success = PublishSubject<Null>()
    ..name = 'import.success';
}

class ImportRequest {
  ImportRequest(
      {required this.text, this.onSuccess, this.getEntropy, this.saveSecret});
  final String text;
  final Future<void> Function()? onSuccess;
  final Future<String> Function(String id)? getEntropy;
  final Future<void> Function(Secret secret)? saveSecret;
  @override
  String toString() =>
      'ImportRequest(text=$text, onSuccess=$onSuccess, getEntropy=$getEntropy, saveSecret=$saveSecret)';
}
