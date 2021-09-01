part of 'block.dart';

// primary key

String _headerToKey(int height) {
  return '${height.toString()}';
}

class _HeaderKey extends Key<Block> {
  @override
  String getKey(Block header) => _headerToKey(header.height);
}

// really want the most recent saved, the max height...
extension ByHeaderMethodsForBlock on Index<_HeaderKey, Block> {
  Block? getOne(int height) => getByKeyStr(_headerToKey(height)).firstOrNull;
}
