import 'package:ravencoin_back/records/raw/secret.dart';
import 'package:rxdart/rxdart.dart';

class ImportRequest {
  final String text;
  final Future<void> Function()? onSuccess;
  final Future<String> Function(String id)? getEntropy;
  final Future<void> Function(Secret secret)? saveSecret;

  ImportRequest(
      {required this.text, this.onSuccess, this.getEntropy, this.saveSecret});
  @override
  String toString() =>
      'ImportRequest(text=$text, onSuccess=$onSuccess, getEntropy=$getEntropy, saveSecret=$saveSecret)';
}

class Import {
  final attempt = BehaviorSubject<ImportRequest?>.seeded(null);
  final result = BehaviorSubject<ImportRequest?>.seeded(null);
  final success = PublishSubject<Null>();
}
