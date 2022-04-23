import 'package:rxdart/rxdart.dart';

class ImportRequest {
  final String text;
  ImportRequest({required this.text});
  @override
  String toString() => 'ImportRequest(text=$text)';
}

class Import {
  final attempt = BehaviorSubject<ImportRequest?>.seeded(null);
  final result = BehaviorSubject<ImportRequest?>.seeded(null);
}
