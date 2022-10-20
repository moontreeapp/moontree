part of 'note.dart';

// primary key

class _IdKey extends Key<Note> {
  @override
  String getKey(Note note) => note.id;
}

extension ByIdMethodsForNote on Index<_IdKey, Note> {
  Note? getOne(String noteId) => getByKeyStr(noteId).firstOrNull;
}
