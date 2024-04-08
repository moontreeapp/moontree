import 'package:flutter/material.dart';

/// simple example of an AnimatedList
class SimpleAnimatedListUseExample extends StatefulWidget {
  const SimpleAnimatedListUseExample({super.key});

  @override
  SimpleAnimatedListUseExampleState createState() =>
      SimpleAnimatedListUseExampleState();
}

class SimpleAnimatedListUseExampleState
    extends State<SimpleAnimatedListUseExample> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<String> _items = [];

  @override
  void initState() {
    super.initState();
    _items = ['Item 1', 'Item 2']; // Initial items
  }

  void _addItem() {
    _items.insert(0, 'Item ${_items.length + 1}');
    _listKey.currentState
        ?.insertItem(0, duration: const Duration(milliseconds: 500));
  }

  void _removeItem(int index) {
    final item = _items.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => _buildItem(item, animation),
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildItem(String item, Animation<double> animation) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOutCirc, // Specify your desired curve here
    );
    return SizeTransition(
      sizeFactor: curvedAnimation,
      child: GestureDetector(
        onTap: _addItem,
        child: ListTile(
          title: Text(item, style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: _listKey,
      initialItemCount: _items.length,
      itemBuilder: (context, index, animation) {
        return _buildItem(_items[index], animation);
      },
    );
  }
}
