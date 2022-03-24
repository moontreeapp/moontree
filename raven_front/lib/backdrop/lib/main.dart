import 'package:flutter/material.dart';
import './sample_content/back_layer_content.dart';
import './sample_content/layer_content.dart';
import './sliding_panel.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Layered Widget',
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 0, 132, 255),
          colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blue)
              .copyWith(secondary: Colors.blue)),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
      ),
      body: SlidingPanel(
        backContent: const BackLayerContent(),
        frontContent: LayerContent(title: 'Front Content'),
        controlHeight: 0.5,
      ),
    );
  }
}
