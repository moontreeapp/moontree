import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

import '_type_id.dart';

part 'note.g.dart';

@HiveType(typeId: TypeId.Note)
class Note with EquatableMixin {
  @HiveField(0)
  final String transactionId;

  @HiveField(1)
  final String note;

  const Note({
    required this.transactionId,
    required this.note,
  });

  @override
  List<Object> get props => [
        transactionId,
        note,
      ];

  @override
  String toString() => 'Note(transactionId: $transactionId, note: $note)';

  String get id => transactionId;
}
