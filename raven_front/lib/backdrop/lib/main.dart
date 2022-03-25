import 'package:flutter/material.dart';
import './sample_content/back_layer_content.dart';
import './sample_content/front_layer_content.dart';
import './sliding_panel_widget.dart';

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
      home: MyHomePage(),
    );
  }
}

Widget header = Padding(
  padding: const EdgeInsets.all(8.0),
  child: Container(
    color: Colors.white,
    width: double.infinity,
    child: const Center(
      child:
          Text('Content', style: TextStyle(fontSize: 20, color: Colors.black)),
    ),
  ),
);

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Wallet'),
        ),
        body: SlidingPanel(
          borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15), topRight: Radius.circular(15)),
          controlHeight: MediaQuery.of(context).size.height / 2,
          header: header,
          // the content at the front layer, scroll controller must be passed to the listview builder
          // to prevent scrolling while the panel not fully shown
          panelBuilder: (scrollController) =>
              FrontLayerContent(scrollController),
          //Content at the back layer
          body: const BackLayerContent(),
        ));
  }
}
