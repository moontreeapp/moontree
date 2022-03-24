import 'package:flutter/material.dart';

import 'list_item.dart';

class LayerContent extends StatefulWidget {
  final String title;

  LayerContent({Key? key, required this.title}) : super(key: key);

  @override
  State<LayerContent> createState() => _LayerContentState();
}

class _LayerContentState extends State<LayerContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          color: Colors.white),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child: Text('Front Content',
                  style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          Expanded(
            child: Container(
              child: ListView.builder(
                itemCount: 100,
                itemBuilder: (BuildContext context, int index) {
                  return const ListItem();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
