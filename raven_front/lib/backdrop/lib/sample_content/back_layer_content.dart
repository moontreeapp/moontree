import 'package:flutter/material.dart';

class BackLayerContent extends StatefulWidget {
  const BackLayerContent({Key? key}) : super(key: key);

  @override
  State<BackLayerContent> createState() => _BackLayerContentState();
}

class _BackLayerContentState extends State<BackLayerContent> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Center(
              child:
                  Text('', style: TextStyle(fontSize: 20, color: Colors.black)),
            ),
          ),
          Container(
            width: 150.0,
            height: 150.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
    );
  }
}
