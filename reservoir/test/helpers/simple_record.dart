import 'package:equatable/equatable.dart';

class SimpleRecord with EquatableMixin {
  final String key;
  final String value;
  SimpleRecord(this.key, this.value);

  @override
  List<Object?> get props => [key];
}
