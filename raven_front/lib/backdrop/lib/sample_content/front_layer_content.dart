import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'list_item.dart';

class FrontLayerContent extends StatefulWidget {
  final ScrollController scrollController;
  FrontLayerContent(this.scrollController);

  @override
  State<FrontLayerContent> createState() => _LayerContentState();
}

Widget header = Center(
  child: Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Container(
      width: 30,
      height: 8,
      decoration: BoxDecoration(
          color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
    ),
  ),
);

class _LayerContentState extends State<FrontLayerContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Colors.white),
      child: Column(
        children: [
          header,
          Expanded(
            child: Container(
              child: ListView.builder(
                dragStartBehavior: DragStartBehavior.start,
                physics: const BouncingScrollPhysics(),
                controller: widget.scrollController,
                itemCount: 100,
                itemBuilder: (BuildContext context, int index) {
                  return const ListItem();
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
