part of 'block.dart';

// primary key

// only latest block saved in proclaim at this time
class _IdKey extends Key<Block> {
  @override
  String getKey(Block header) => Block.blockKey();
}
