import 'package:client_front/application/receive/cubit.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/presentation/components/components.dart'
    as components;
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/presentation/widgets/widgets.dart';
import 'package:share/share.dart';

class Receive extends StatelessWidget {
  const Receive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return flutter_bloc.BlocBuilder<ReceiveViewCubit, ReceiveViewState>(
        bloc: components.cubits.receiveView
          ..setAddress(Current.wallet), // go get an address
        builder: (BuildContext context, ReceiveViewState state) {
          return FrontCurve(
              alignment: Alignment.topCenter,
              child: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: ReceiveContent(
                  cubit: components.cubits.receiveView,
                ),
              ));
        });
  }
}

class ReceiveContent extends StatelessWidget {
  final ReceiveViewCubit cubit;
  ReceiveContent({Key? key, required this.cubit}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final smallScreen = MediaQuery.of(context).size.height < 640;
    final height = 1.ofAppHeight;
    return Stack(
      alignment: Alignment.topCenter,
      children: <Widget>[
        SingleChildScrollView(
            child: Container(
                height: height,
                alignment: Alignment.topCenter,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        padding: const EdgeInsets.only(top: 16),
                        child: GestureDetector(
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: cubit.address));
                              streams.app.snack.add(Snack(
                                  message: 'Address copied to clipboard'));
                              // not formatted the same...
                              //ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                              //  content: new Text("Copied to Clipboard"),
                              //));
                            },
                            child: Center(
                                child: cubit.notGenerating
                                    ? QrImage(
                                        backgroundColor: Colors.white,
                                        data: cubit.address,
                                        foregroundColor: AppColors.primary,
                                        //embeddedImage: Image.asset(
                                        //        'assets/logo/moontree_logo.png')
                                        //    .image,
                                        size: smallScreen ? 150 : 300.0)
                                    : Container(height: 0)))),
                    SelectableText(
                      cubit.address,
                      style: Theme.of(context)
                          .textTheme
                          .caption!
                          .copyWith(color: AppColors.black87),
                      showCursor: true,
                      toolbarOptions:
                          const ToolbarOptions(copy: true, selectAll: true),
                    ),
                    if (!smallScreen) SizedBox(height: 72.figmaH)
                  ],
                ))),
        if (cubit.notGenerating)
          Stack(
            alignment: Alignment.bottomCenter,
            children: <Widget>[
              Container(height: height + 48),
              KeyboardHidesWidgetWithDelay(
                  child: components.containers.navBar(context,
                      child: Row(children: <Widget>[
                        components.buttons.actionButton(
                          context,
                          label: 'Share',
                          focusNode: FocusNode(),
                          onPressed: () => Share.share(cubit.address),
                        )
                      ]))),
            ],
          ),
      ],
    );
  }
}
