import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:raven_back/raven_back.dart';
import 'package:raven_back/streams/app.dart';
import 'package:raven_front/components/components.dart';
import 'package:raven_front/pages/manage/assets.dart';
import 'package:raven_front/theme/theme.dart';
import 'package:raven_front/widgets/widgets.dart';

class NavBar extends StatefulWidget {
  String? symbol;
  NavBar({Key? key, this.symbol}) : super(key: key);

  @override
  _NavBarState createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    var assetType = widget.symbol ?? '';
    //var assetType = Asset.assetTypeOf(streams.app.manage.asset.value ?? '');
    return Container(
      height: MediaQuery.of(context).size.height * (118 / 760),
      padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 0),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16), topRight: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
              color: const Color(0x33000000),
              offset: Offset(0, 5),
              blurRadius: 5),
          BoxShadow(
              color: const Color(0x1F000000),
              offset: Offset(0, 3),
              blurRadius: 14),
          BoxShadow(
              color: const Color(0x3D000000),
              offset: Offset(0, 8),
              blurRadius: 10)
        ],
      ),
      child: ListView(
        //mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // we will need to make these buttons dependant upon the navigation
          // of the front page through streams but for now, we'll show they
          // can changed based upon whats selected:
          streams.app.context.value == AppContext.wallet
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    components.buttons.actionButton(
                      context,
                      label: 'send',
                      link: '/transaction/send',
                    ),
                    SizedBox(width: 16),
                    components.buttons.actionButton(
                      context,
                      label: 'receive',
                      link: '/transaction/receive',
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: streams.app.page.value == 'Home'
                      ? <Widget>[
                          components.buttons.actionButton(
                            context,
                            label: 'create',
                            onPressed: _produceCreateModal,
                          )
                        ]
                      : <Widget>[
                          if ([AssetType.Main, AssetType.Sub]
                              .contains(assetType)) ...[
                            components.buttons.actionButton(context,
                                label: 'create',
                                onPressed: streams.app.page.value == 'Asset'
                                    ? _produceSubCreateModal
                                    : () {}),
                            SizedBox(width: 16)
                          ],
                          if ([
                            AssetType.Qualifier,
                            AssetType.QualifierSub,
                          ].contains(assetType)) ...[
                            components.buttons.actionButton(context,
                                label: 'create',
                                onPressed: streams.app.page.value == 'Asset'
                                    //? _produceSubQualifierModal
                                    ? () => Navigator.pushNamed(
                                          components.navigator.routeContext!,
                                          '/create/qualifiersub',
                                          arguments: {'symbol': 'QualifierSub'},
                                        )
                                    : () {}),
                            SizedBox(width: 16)
                          ],
                          components.buttons.actionButton(context,
                              label: 'manage', onPressed: () {
                            // if main do this
                            _produceMainManageModal();
                            // if sub do this
                            //_produceSubManageModal();
                            // if other do this
                            //
                          }),
                        ],
                ),
          SizedBox(height: 6),
          Padding(
              padding: EdgeInsets.only(left: 0, right: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  sectorIcon(appContext: AppContext.wallet),
                  sectorIcon(appContext: AppContext.manage),
                  sectorIcon(appContext: AppContext.swap),
                ],
              ))
        ],
      ),
      //  ),
    );
  }

  Widget sectorIcon({required AppContext appContext}) => Container(
      height: 56,
      width: (MediaQuery.of(context).size.width - 32 - 0) / 3,
      alignment: Alignment.center,
      child: IconButton(
        onPressed: () {
          streams.app.context.add(appContext);
          if (!['Home', 'Manage', 'Swap'].contains(streams.app.page.value)) {
            Navigator.popUntil(components.navigator.routeContext!,
                ModalRoute.withName('/home'));
          }
        },
        icon: Icon({
          AppContext.wallet: MdiIcons.wallet,
          AppContext.manage: MdiIcons.plusCircle,
          AppContext.swap: MdiIcons.swapHorizontalBold,
        }[appContext]!),
        iconSize: streams.app.context.value == appContext ? 32 : 24,
        color: streams.app.context.value == appContext
            ? AppColors.primary
            : Color(0x995C6BC0),
      ));

  void _produceCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Create).build();
  }

  void _produceSubCreateModal() {
    SelectionItems(context, modalSet: SelectionSet.Sub_Asset).build();
  }

  void _produceMainManageModal() async {
    await SelectionItems(context, modalSet: SelectionSet.MainManage).build();
  }
}
