import 'package:flutter/material.dart';

class CustomAutocomplete extends StatelessWidget {
  final TextEditingController _textEditingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final GlobalKey _autocompleteKey = GlobalKey();

  final List<String> _options = <String>[
    'aardvark',
    'bobcat',
    'chameleon',
  ];

  CustomAutocomplete({Key? key}) : super(key: key);

  void clear() {
    _textEditingController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      key: _autocompleteKey,
      focusNode: _focusNode,
      textEditingController: _textEditingController,
      optionsBuilder: (TextEditingValue textEditingValue) {
        return _options.where((String option) {
          return option.contains(textEditingValue.text.toLowerCase());
        }).toList();
      },
      optionsViewBuilder: (BuildContext context,
          AutocompleteOnSelected<String> onSelected, Iterable<String> options) {
        return Material(
          elevation: 4.0,
          child: ListView(
            children: options
                .map((String option) => GestureDetector(
                      onTap: () {
                        onSelected(option);
                      },
                      child: ListTile(
                        title: Text(option),
                      ),
                    ))
                .toList(),
          ),
        );
      },
    );
  }
}
