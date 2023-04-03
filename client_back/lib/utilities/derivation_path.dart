import 'package:client_back/records/types/node_exposure.dart';
import 'package:client_back/records/types/net.dart';

/// because evrmore uses the same path as raven, it is not necessary to modify
String getDerivationPath({
  int? index,
  NodeExposure exposure = NodeExposure.external,
  Net net = Net.main,
}) =>
    "m/44'/${net == Net.main ? '175' : '1'}'/0'/"
    '${<NodeExposure, String>{
      NodeExposure.external: '0',
      NodeExposure.internal: '1',
    }[exposure]!}${index == null ? '' : '/$index'}';
