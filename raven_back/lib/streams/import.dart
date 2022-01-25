import 'package:rxdart/rxdart.dart';

class ImportRequest {
  final String text;
  final String accountId;
  ImportRequest({required this.text, required this.accountId});
  @override
  String toString() => 'ImportRequest(text=$text, accountId=$accountId)';
}

class Import {
  final attempt = BehaviorSubject<ImportRequest?>.seeded(null);
  final success = BehaviorSubject<bool?>.seeded(null);
}
