import 'package:flutter/material.dart';

class SwtichChoice extends StatefulWidget {
  final String label;
  final String? description;
  final bool initial;
  final Future<void> Function(bool)? onChanged;
  const SwtichChoice({
    this.label = 'Choice',
    this.initial = false,
    this.onChanged = null,
    this.description,
  }) : super();

  @override
  _SwtichChoice createState() => _SwtichChoice();
}

class _SwtichChoice extends State<SwtichChoice> {
  late bool choice;

  @override
  void initState() {
    super.initState();
    choice = widget.initial;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
        Widget>[
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: <Widget>[
        Text(widget.label, style: Theme.of(context).textTheme.bodyText1),
        Switch(
            value: choice,
            onChanged: (value) async {
              if (widget.onChanged != null) {
                await widget.onChanged!(value);
              }
              setState(() => choice = value);
            }),
      ]),
      if (widget.description != null) SizedBox(height: 8),
      if (widget.description != null)
        Text(
          widget.description!,
          style: Theme.of(context).textTheme.bodyText2,
        ),
    ]);
  }
}
