part of 'note.dart';

// primary key

class _NoteIdKey extends Key<Note> {
  @override
  String getKey(Note note) => note.id;
}

extension ByIdMethodsForNote on Index<_NoteIdKey, Note> {
  Note? getOne(String noteId) => getByKeyStr(noteId).firstOrNull;
}
