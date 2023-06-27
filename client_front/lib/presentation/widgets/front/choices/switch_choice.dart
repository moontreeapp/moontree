import 'package:flutter/material.dart';

class SwtichChoice extends StatefulWidget {
  final String label;
  final String? description;
  final bool hideDescription;
  final bool initial;
  final Future<void> Function(bool)? onChanged;
  const SwtichChoice({
    this.label = 'Choice',
    this.initial = false,
    this.onChanged = null,
    this.hideDescription = false,
    this.description,
  }) : super();

  @override
  _SwtichChoice createState() => _SwtichChoice();
}

class _SwtichChoice extends State<SwtichChoice> {
  late bool choice;
  late bool hidden;

  @override
  void initState() {
    super.initState();
    choice = widget.initial;
    hidden = widget.hideDescription;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                GestureDetector(
                    onTap: () => setState(() {
                          hidden = !hidden;
                        }),
                    child: Text(widget.label,
                        style: Theme.of(context).textTheme.bodyLarge)),
                Switch(
                    value: choice,
                    onChanged: (bool value) async {
                      if (widget.onChanged != null) {
                        await widget.onChanged!(value);
                      }
                      setState(() => choice = value);
                    }),
              ]),
          if (widget.description != null && !hidden) const SizedBox(height: 8),
          if (widget.description != null && !hidden)
            Text(
              widget.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
        ]);
  }
}
