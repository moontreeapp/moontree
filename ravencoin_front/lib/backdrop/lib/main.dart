import 'package:flutter/material.dart';
import './sample_content/back_layer_content.dart';
import './sample_content/front_layer_content.dart';
import 'modified_draggable_scrollable_sheet.dart' as slide;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Panel',
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 0, 132, 255),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blue)),
      home: const SlidingPanel(),
    );
  }
}

class SlidingPanel extends StatefulWidget {
  const SlidingPanel({Key? key}) : super(key: key);

  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel> {
  final slide.DraggableScrollableController controller =
      slide.DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Stack(
        children: <Widget>[
          const BackLayerContent(),
          slide.DraggableScrollableActuator(
            child: slide.DraggableScrollableSheet(
              controller: controller,
              initialChildSize: 0.5,
              maxChildSize: 1,
              minChildSize: 0.5,
              snap: true,
              builder:
                  (BuildContext context, ScrollController scrollController) =>
                      FrontLayerContent(scrollController),
            ),
          )
        ],
      ),
    );
  }
}
