import 'dart:async';

// TODO: More robust checking, errors, etc for coder

// Multiple reads can happen at once
// Only one write can happen at once
// Reads cannot occur during writes.
// Writes cannot occur during reads.

// This class will always prioritize writes
// TODO: Do we want to prioritize reads sometimes or flip-flop between?
class ReaderWriterLock {
  int _read_count = 0;
  bool _is_writing_or_waiting_to_write = false;

  final List<Completer<void>> _write_queue = <Completer<void>>[];
  Completer<void> _read_after_write = Completer();

  Future<void> enterRead() async {
    while (_is_writing_or_waiting_to_write) {
      await _read_after_write.future;
    }
    _read_count += 1;
  }

  Future<void> exitRead() async {
    _read_count -= 1;
    if (_read_count == 0 && _write_queue.isNotEmpty) {
      _write_queue.removeAt(0).complete();
    }
  }

  Future<void> enterWrite() async {
    final old_bool = _is_writing_or_waiting_to_write;
    _is_writing_or_waiting_to_write = true;
    if (old_bool || _read_count != 0) {
      final completer = Completer();
      _write_queue.add(completer);
      await completer.future;
    }
  }

  Future<void> exitWrite() async {
    if (_write_queue.isNotEmpty) {
      _write_queue.removeAt(0).complete();
    } else {
      _is_writing_or_waiting_to_write = false;
      final old_completer = _read_after_write;
      _read_after_write = Completer();
      old_completer.complete();
    }
  }
}
