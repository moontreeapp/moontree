import 'package:ravencoin_back/records/types/node_exposure.dart';

String getDerivationPath(int index,
        {exposure = NodeExposure.external, bool mainnet = true}) =>
    "m/44'/${mainnet ? '175' : '1'}'/0'/"
    '${{
      NodeExposure.external: '0',
      NodeExposure.internal: '1',
    }[exposure]!}/$index';
