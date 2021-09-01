part of 'block.dart';

// primary key

String _headerToKey() {
  return 'height';
}

class _HeaderKey extends Key<Block> {
  @override
  String getKey(Block header) => _headerToKey();
}
