import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/records/types/status_type.dart';

import '_type_id.dart';

part 'status.g.dart';

@HiveType(typeId: TypeId.Status)
class Status with EquatableMixin {
  @HiveField(0)
  final String linkId; // the headers, address, asset

  @HiveField(1)
  final StatusType statusType; // headers, address, asset

  @HiveField(2)
  final String? status;

  const Status({
    required this.linkId,
    required this.statusType,
    this.status,
  });

  @override
  List<Object?> get props => <Object?>[
        linkId,
        statusType,
        status,
      ];

  @override
  String toString() {
    return 'Status('
        'linkId: $linkId, statusType: $statusType, status: $status)';
  }

  String get id => key(linkId, statusType);
  static String key(String linkId, StatusType statusType) =>
      linkId + statusType.name;
}
