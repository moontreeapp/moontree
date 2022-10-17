import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
import 'package:ravencoin_back/extensions/extensions.dart';
import 'package:ravencoin_back/records/types/status_type.dart';

import '_type_id.dart';

part 'status.g.dart';

@HiveType(typeId: TypeId.Status)
class Status with EquatableMixin {
  @HiveField(0)
  String linkId; // the headers, address, asset

  @HiveField(1)
  StatusType statusType; // headers, address, asset

  @HiveField(2)
  String? status;

  Status({
    required this.linkId,
    required this.statusType,
    this.status,
  });

  @override
  List<Object?> get props => [
        linkId,
        statusType,
        status,
      ];

  @override
  String toString() {
    return 'Status('
        'linkId: $linkId, statusType: $statusType, status: $status)';
  }

  String get id => statusId(linkId, statusType);
  static String statusId(String linkId, StatusType statusType) =>
      linkId + statusType.name;
}
