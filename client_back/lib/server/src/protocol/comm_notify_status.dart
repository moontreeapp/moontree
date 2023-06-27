/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

class NotifyChainStatus extends _i1.SerializableEntity {
  NotifyChainStatus({
    this.id,
    required this.chainName,
    required this.status,
  });

  factory NotifyChainStatus.fromJson(
    Map<String, dynamic> jsonSerialization,
    _i1.SerializationManager serializationManager,
  ) {
    return NotifyChainStatus(
      id: serializationManager.deserialize<int?>(jsonSerialization['id']),
      chainName: serializationManager
          .deserialize<String>(jsonSerialization['chainName']),
      status:
          serializationManager.deserialize<int>(jsonSerialization['status']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String chainName;

  int status;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chainName': chainName,
      'status': status,
    };
  }
}
