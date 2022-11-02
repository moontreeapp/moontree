import 'package:ravencoin_back/records/types/node_exposure.dart';

/// because evrmore uses the same path as raven, it is not necessary to modify
String getDerivationPath(
  int index, {
  exposure = NodeExposure.external,
  bool mainnet = true,
}) =>
    "m/44'/${mainnet ? '175' : '1'}'/0'/"
    '${{
      NodeExposure.external: '0',
      NodeExposure.internal: '1',
    }[exposure]!}/$index';
