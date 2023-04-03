/// a Security has one top-level, or primary metadata.
/// a Metadata can have subMetadatas like...
/// a logo represented by an ipfs hash inside a
/// json string represented by an ipfs hash.
/// these are linked by parents

import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:client_back/records/types/chain.dart';
import 'package:client_back/records/types/metadata_type.dart';
import 'package:client_back/records/types/net.dart';

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

  @HiveField(6, defaultValue: Chain.ravencoin)
  final Chain chain;

  @HiveField(7, defaultValue: Net.main)
  final Net net;

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
    required this.chain,
    required this.net,
  });

  @override
  List<Object> get props => <Object>[
        symbol,
        metadata,
        data ?? '',
        kind,
        parent ?? '',
        logo,
        chain,
        net,
      ];

  @override
  String toString() => 'Metadata(symbol: $symbol, metadata: $metadata, '
      'data: $data, kind: $kind, parent: $parent, logo: $logo, '
      '${ChainNet(chain, net).readable}';

  factory Metadata.from(
    Metadata metadata, {
    String? symbol,
    String? metadataValue,
    String? data,
    MetadataType? kind,
    String? parent,
    bool? logo,
    Chain? chain,
    Net? net,
  }) =>
      Metadata(
        logo: logo ?? metadata.logo,
        parent: parent ?? metadata.parent,
        kind: kind ?? metadata.kind,
        data: data ?? metadata.data,
        metadata: metadataValue ?? metadata.metadata,
        symbol: symbol ?? (chain != null ? chain.symbol : metadata.symbol),
        chain: chain ?? metadata.chain,
        net: net ?? metadata.net,
      );

  static String key(String symbol, String metadata, Chain chain, Net net) =>
      '$symbol:$metadata:${ChainNet(chain, net).key}';

  String get id => key(symbol, metadata, chain, net);
  String get metadataTypeName => kind.name;
}
