import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share/share.dart';
import 'package:client_back/client_back.dart';
import 'package:client_back/streams/app.dart';
import 'package:client_front/domain/utils/extensions.dart';
import 'package:client_front/infrastructure/services/lookup.dart';
import 'package:client_front/application/receive/cubit.dart';
import 'package:client_front/presentation/widgets/other/buttons.dart';
import 'package:client_front/presentation/theme/theme.dart';
import 'package:client_front/presentation/widgets/other/page.dart';
import 'package:client_front/presentation/services/services.dart' show screen;
import 'package:client_front/presentation/components/components.dart'
    as components;

class Receive extends StatelessWidget {
  const Receive({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    components.cubits.receiveView.setAddress(Current.wallet, force: true);
    final smallScreen = screen.app.height < 640;
    return BlocBuilder<ReceiveViewCubit, ReceiveViewState>(
        builder: (BuildContext context, ReceiveViewState state) {
      return PageStructure(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(
                      text: components.cubits.receiveView.address));
                  streams.app.snack
                      .add(Snack(message: 'Address copied to clipboard'));
                  // not formatted the same...
                  //ScaffoldMessenger.of(context).showSnackBar(new SnackBar(
                  //  content: new Text("Copied to Clipboard"),
                  //));
                },
                child: Center(
                    child: components.cubits.receiveView.notGenerating
                        ? QrImage(
                            backgroundColor: Colors.white,
                            data: components.cubits.receiveView.address,
                            foregroundColor: AppColors.primary,
                            //embeddedImage: Image.asset(
                            //        'assets/logo/moontree_logo.png')
                            //    .image,
                            size: smallScreen ? 150 : 300.0)
                        : Container(height: 0))),
            SelectableText(
              components.cubits.receiveView.address,
              style: Theme.of(context)
                  .textTheme
                  .caption!
                  .copyWith(color: AppColors.black87),
              showCursor: true,
              toolbarOptions: const ToolbarOptions(copy: true, selectAll: true),
            ),
            if (!smallScreen) SizedBox(height: 72.figmaH)
          ],
          firstLowerChildren: <Widget>[
            BottomButton(
              label: 'Share',
              focusNode: FocusNode(),
              onPressed: () =>
                  Share.share(components.cubits.receiveView.address),
            )
          ],
          secondLowerChildren: <Widget>[]);
    });
  }
}
