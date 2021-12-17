part of 'block.dart';

// primary key

// only latest block saved in reservoir at this time
class _HeaderKey extends Key<Block> {
  @override
  String getKey(Block header) => Block.blockKey();
}
