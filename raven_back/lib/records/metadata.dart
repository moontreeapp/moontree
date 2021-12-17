/// a Security has one top-level, or primary metadata.
/// a Metadata can have subMetadatas like...
/// a logo represented by an ipfs hash inside a
/// json string represented by an ipfs hash.
/// these are linked by parents

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:raven_back/records/metadata_type.dart';
import 'package:raven_back/extensions/object.dart';

import '_type_id.dart';

part 'metadata.g.dart';

@HiveType(typeId: TypeId.Metadata)
class Metadata with EquatableMixin {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String metadata; // typically ipfs hash

  @HiveField(2)
  final String? data; // content of ipfs hash

  @HiveField(3)
  final MetadataType kind; // what is the data? image, video, json, html? etc?

  @HiveField(4)
  final String? parent; // matches metadata

  @HiveField(5)
  final bool logo; // helper flag for logos (most chilren will be logos)

  /// metadata is often an ipfsHash of json which often includes an ipfsHash
  /// for the logo. Instead of looking it up everytime, since there is no hard
  /// format, we save the ipfsLogo hash on the object when we figure it out.
  /// we do not derive the ipfsLogo upon record creation, instead we wait until
  /// the ...
  /// null means we have not looked, empty string means we've looked and found
  /// no viable logo in the metadata, anything else should be a ipfs hash of the
  /// logo, or any kind of hash (since the hash matches the filename).

  const Metadata({
    required this.symbol,
    required this.metadata,
    required this.data,
    required this.kind,
    this.parent,
    this.logo = false,
  });

  @override
  List<Object> get props => [
        symbol,
        metadata,
        data ?? '',
        kind,
        parent ?? '',
        logo,
      ];

  @override
  String toString() => 'Metadata(symbol: $symbol, metadata: $metadata, '
      'data: $data, kind: $kind, parent: $parent, logo: $logo)';

  static String metadataKey(String symbol, String metadata) =>
      '$symbol:$metadata';
  String get metadataId => '$symbol:$metadata';
  String get metadataTypeName => kind.enumString;
}
