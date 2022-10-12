part of 'block.dart';

// primary key

// only latest block saved in proclaim at this time
class _HeaderKey extends Key<Block> {
  @override
  String getKey(Block header) => Block.key(header.chain, header.net);
}
