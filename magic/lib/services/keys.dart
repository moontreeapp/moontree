//import 'package:flutter/material.dart';
//import 'package:magic/presentation/pages/hypyr/home.dart'
//    show CommentsContainerState;

//late GlobalKey<AnimatedListState> commentListKey;
//late GlobalKey<CommentsContainerState> commentsContainerKey = GlobalKey();

void init() {
  // not necessary any more
  //commentListKey = GlobalKey();
}

// if you use a global key on a widget that has a controller:
// globalKey.currentState._controller.forward();
// we were going to use this solution but instead we just set the back function.
