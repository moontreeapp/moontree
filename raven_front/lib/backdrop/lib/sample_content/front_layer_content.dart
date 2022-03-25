import 'package:flutter/material.dart';

import 'list_item.dart';

class FrontLayerContent extends StatefulWidget {
  ScrollController scrollController;
  FrontLayerContent(this.scrollController);

  @override
  State<FrontLayerContent> createState() => _LayerContentState();
}

class _LayerContentState extends State<FrontLayerContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Colors.white),
      child: Container(
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          controller: widget.scrollController,
          itemCount: 100,
          itemBuilder: (BuildContext context, int index) {
            return ListItem();
          },
        ),
      ),
    );
  }
}
