import 'dart:typed_data';

import 'package:dart_cid/src/decode_cid.dart' show CIDInfo;
import 'package:dart_cid/dart_cid.dart' show CID;
import 'package:client_back/streams/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:client_back/client_back.dart';
import 'package:client_front/application/infrastructure/connection/cubit.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/utils/animation.dart' as animation;
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/widgets/other/fading.dart';
import 'package:client_front/presentation/widgets/front/choices/blockchain_choice.dart'
    show navToBlockchain;
import 'package:moontree_utils/extensions/string.dart';
import 'package:moontree_utils/extensions/uint8list.dart';

class ConnectionLight extends StatelessWidget {
  const ConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionStatusCubit, ConnectionStatusCubitState>(
        builder: (BuildContext context, ConnectionStatusCubitState state) {
      final Color connectionStatusColor = statusColor(state);
      return FadeIn(
          duration: animation.slowFadeDuration,
          child: GestureDetector(
            onLongPress: () {
              print('testing done here');
              CIDInfo cidInfoV0 = CID
                  .decodeCid('QmRKs2ZfuwvmZA3QAWmCqrGUjV9pxtBUDP3wuc6iVGnjA2');
              print('QmRKs2ZfuwvmZA3QAWmCqrGUjV9pxtBUDP3wuc6iVGnjA2'
                  .base58Decode
                  .toEncodedString);
              print(Uint8List.fromList(cidInfoV0.multihashDigest)
                  .toEncodedString);
              CIDInfo cidInfo = CID.decodeCid(
                  'bafybeibml5uieyxa5tufngvg7fgwbkwvlsuntwbxgtskoqynbt7wlchmfm');
              final encoded = Uint8List.fromList(cidInfo.multihashDigest);
              print(encoded.length);
              print(encoded.toEncodedString);
              streams.app.behavior.snack.add(
                  Snack(message: state.status.name, label: "ok", copy: 'abc'));
            },
            onTap: navToBlockchain,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              alignment: Alignment.center,
              padding: EdgeInsets.zero,
              child: pros.settings.chain == Chain.none
                  ? IconButton(
                      splashRadius: 26,
                      padding: EdgeInsets.zero,
                      icon: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 8,
                        width: 8,
                        decoration: BoxDecoration(
                          color: connectionStatusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: navToBlockchain,
                    )
                  : Stack(alignment: Alignment.center, children: <Widget>[
                      ColorFiltered(
                          colorFilter: ColorFilter.mode(
                              connectionStatusColor, BlendMode.srcIn),
                          child: components.icons.assetAvatar(
                            pros.settings.chain.symbol,
                            net: pros.settings.net,
                            height: 28,
                            width: 28,
                          )),
                      components.icons.assetAvatar(pros.settings.chain.symbol,
                          net: pros.settings.net, height: 24, width: 24),
                    ]),
            ),
          ));
    });
  }

  Color statusColor(ConnectionStatusCubitState state) {
    if (state.status == ConnectionStatus.connected && !state.busy) {
      return AppColors.logoGreen;
    } else if (state.status == ConnectionStatus.connected && state.busy) {
      return AppColors.lightGreen;
    } else if (state.status == ConnectionStatus.connecting) {
      return AppColors.yellow;
    } else if (state.status == ConnectionStatus.disconnected) {
      return AppColors.error;
    }
    return AppColors.error;
  }
}

class SpoofedConnectionLight extends StatelessWidget {
  const SpoofedConnectionLight({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const Color connectionStatusColor = AppColors.success;
    final ColorFiltered icon = ColorFiltered(
        colorFilter:
            const ColorFilter.mode(connectionStatusColor, BlendMode.srcATop),
        child: SvgPicture.asset('assets/status/icon.svg'));
    return IconButton(
      splashRadius: 24,
      padding: EdgeInsets.zero,
      onPressed: () {},
      icon: icon,
    );
  }
}
