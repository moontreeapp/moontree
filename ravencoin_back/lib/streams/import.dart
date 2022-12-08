import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:rxdart/rxdart.dart';

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

class Import {
  final BehaviorSubject<ImportRequest?> attempt =
      BehaviorSubject<ImportRequest?>.seeded(null);
  final BehaviorSubject<ImportRequest?> result =
      BehaviorSubject<ImportRequest?>.seeded(null);
  // ignore: prefer_void_to_null
  final PublishSubject<Null> success = PublishSubject<Null>();
}
