import 'package:flutter/material.dart';
import './sample_content/back_layer_content.dart';
import './sample_content/front_layer_content.dart';
import 'modified_draggable_scrollable_sheet.dart' as slide;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Panel',
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 0, 132, 255),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blue)),
      home: SlidingPanel(),
    );
  }
}

class SlidingPanel extends StatefulWidget {
  @override
  State<SlidingPanel> createState() => _SlidingPanelState();
}

class _SlidingPanelState extends State<SlidingPanel> {
  final controller = slide.DraggableScrollableController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallet')),
      body: Stack(
        children: [
          const BackLayerContent(),
          slide.DraggableScrollableActuator(
            child: slide.DraggableScrollableSheet(
              controller: controller,
              initialChildSize: 0.5,
              maxChildSize: 1,
              minChildSize: 0.5,
              snap: true,
              builder: (context, scrollController) =>
                  FrontLayerContent(scrollController),
            ),
          )
        ],
      ),
    );
  }
}
