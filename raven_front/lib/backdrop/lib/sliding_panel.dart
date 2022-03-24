import 'package:flutter/material.dart';

import 'sliding_up_panel_widget.dart';

// The StatefulWidget's job is to take in some data and create a State class.
// In this case, the Widget takes a title, and creates a _MyHomePageState.
class SlidingPanel extends StatefulWidget {
  final Widget backContent;
  final Widget frontContent;
  final double controlHeight;

  @override
  _SlidingPanelState createState() => _SlidingPanelState();

  SlidingPanel(
      {required this.backContent,
      required this.frontContent,
      required this.controlHeight});
}

// The State class is responsible for two things: holding some data you can
// update and building the UI using that data.
class _SlidingPanelState extends State<SlidingPanel> {
  // Whether the green box should be visible or invisible

  ///The controller of sliding up panel
  SlidingUpPanelController panelController = SlidingUpPanelController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.backContent,
        SlidingUpPanelWidget(
          child: widget.frontContent,
          controlHeight: widget.controlHeight,
          anchor: 0.4,
          panelController: panelController,
          onTap: () {
            ///Customize the processing logic
            if (SlidingUpPanelStatus.expanded == panelController.status) {
              panelController.collapse();
            } else {
              panelController.expand();
            }
          },
          enableOnTap: true, //Enable the onTap callback for control bar.
          dragDown: (details) {},
          dragStart: (details) {},
          dragCancel: () {},
          dragUpdate: (details) {
            print(
                'dragUpdate,${panelController.status == SlidingUpPanelStatus.dragging ? 'dragging' : ''}');
          },
          dragEnd: (details) {},
        ),
      ],
    );
  }
}
