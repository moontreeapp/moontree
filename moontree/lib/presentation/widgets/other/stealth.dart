import 'package:flutter/material.dart';
import 'package:moontree/presentation/theme/extensions.dart';

class StealthTextFieldWithoutIcon extends StatefulWidget {
  final String value;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final String? Function()? onEditingComplete;
  final String? Function(PointerDownEvent)? onTapOutside;
  final void Function(String)? onChanged;
  final void Function()? toast;
  final bool showCursor;
  final bool autofocus;

  const StealthTextFieldWithoutIcon({
    super.key,
    this.value = '',
    this.keyboardType,
    this.style,
    this.textAlign,
    this.focusNode,
    this.onEditingComplete,
    this.onTapOutside,
    this.onChanged,
    this.toast,
    this.showCursor = false,
    this.autofocus = false,
  });

  @override
  _StealthTextFieldWithoutIconState createState() =>
      _StealthTextFieldWithoutIconState();
}

class _StealthTextFieldWithoutIconState
    extends State<StealthTextFieldWithoutIcon> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _alreadyAutoFocused = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.focusNode?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.autofocus && !_alreadyAutoFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _alreadyAutoFocused = true;
        FocusScope.of(context).requestFocus(_focusNode);
      });
    }
    return TextField(
        controller: _controller,
        focusNode: widget.focusNode ?? _focusNode,
        autocorrect: false,
        enableSuggestions: false,
        showCursor: widget.showCursor,
        cursorRadius: Radius.zero,
        cursorOpacityAnimates: false,
        //cursorWidth: 2.0,
        //cursorHeight: 5.0,
        cursorColor: Colors.black38,
        decoration: InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          //prefixIcon: Icon(
          //  Icons.edit_rounded,
          //  color: Colors.black38,
          //  size: 12,
          //),
          //suffixIcon: Icon(
          //  Icons.edit_rounded,
          //  color: Colors.black38,
          //  size: 12,
          //),
        ),
        keyboardType: widget.keyboardType ?? TextInputType.name,
        textInputAction: TextInputAction.done,
        style: widget.style ??
            Theme.of(context).textTheme.h2!.copyWith(color: Colors.black87),
        textAlign: widget.textAlign ?? TextAlign.center,
        onEditingComplete: () {
          _controller.text =
              (widget.onEditingComplete?.call() ?? null) ?? _controller.text;
          (widget.focusNode ?? _focusNode).unfocus();
          FocusScope.of(context).unfocus();
          widget.toast?.call();
        },
        onChanged: widget.onChanged,
        onTapOutside: (details) {
          if ((widget.focusNode ?? _focusNode).hasFocus) {
            _controller.text = (widget.onTapOutside?.call(details) ?? null) ??
                _controller.text;
            FocusScope.of(context).unfocus();
            widget.toast?.call();
          }
        });
  }
}

class StealthTextField extends StatefulWidget {
  final String value;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final TextStyle? hintLabelStyle;
  final TextStyle? floatingLabelStyle;
  final TextAlign? textAlign;
  final FocusNode? focusNode;
  final String? label;
  final String? hint;
  final String? Function()? onEditingComplete;
  final String? Function(PointerDownEvent)? onTapOutside;
  final void Function(String)? onChanged;
  final void Function()? toast;
  final Widget? onEmptySuffixIcon;
  final Widget? onNotEmptySuffixIcon;
  final bool onNotEmptySuffixIconClear;
  final bool showCursor;
  final bool showIcon;

  const StealthTextField({
    super.key,
    this.value = '',
    this.keyboardType,
    this.style,
    this.hintLabelStyle,
    this.floatingLabelStyle,
    this.textAlign,
    this.focusNode,
    this.label,
    this.hint,
    this.onEditingComplete,
    this.onTapOutside,
    this.onChanged,
    this.toast,
    this.onEmptySuffixIcon,
    this.onNotEmptySuffixIcon,
    this.onNotEmptySuffixIconClear = false,
    this.showCursor = false,
    this.showIcon = true,
  });

  @override
  _StealthTextFieldState createState() => _StealthTextFieldState();
}

class _StealthTextFieldState extends State<StealthTextField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFirstFocus = true;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.value;
    _controller.addListener(_updateText);
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateText);
    _controller.removeListener(_handleFocusChange);
    _controller.dispose();
    widget.focusNode?.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _updateText() {
    setState(() {
      // This empty setState call will trigger a rebuild every time the text changes
    });
  }

  void _handleFocusChange() {
    if ((widget.focusNode ?? _focusNode).hasFocus && _isFirstFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
      _isFirstFocus = false;
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        alignment: Alignment.center,
        children: [
          if (widget.showIcon && !(widget.focusNode ?? _focusNode).hasFocus)
            _buildDynamicIcon(),
          TextField(
            controller: _controller,
            focusNode: widget.focusNode ?? _focusNode,
            autocorrect: false,
            enableSuggestions: false,
            showCursor: widget.showCursor,
            cursorRadius: Radius.zero,
            cursorOpacityAnimates: false,
            //cursorWidth: 2.0,
            //cursorHeight: 5.0,
            //cursorColor: Colors.transparent,
            decoration: InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: _controller.text.isEmpty
                    ? widget.onEmptySuffixIcon
                    : widget.onNotEmptySuffixIconClear
                        ? GestureDetector(
                            onTap: () {
                              _controller.text = '';
                              widget.onChanged?.call('');
                              _updateText();
                            },
                            child: widget.onNotEmptySuffixIcon)
                        : widget.onNotEmptySuffixIcon,
                labelText: widget.label,
                labelStyle: widget.floatingLabelStyle,
                floatingLabelStyle: widget.floatingLabelStyle,
                floatingLabelBehavior: FloatingLabelBehavior.always,
                floatingLabelAlignment: FloatingLabelAlignment.start,
                hintText: widget.hint,
                alignLabelWithHint: true,
                hintStyle: widget.hintLabelStyle),
            keyboardType: widget.keyboardType ?? TextInputType.name,
            textInputAction: TextInputAction.done,
            style: widget.style ??
                Theme.of(context)
                    .textTheme
                    .body2!
                    .copyWith(color: Colors.black87),
            textAlign: widget.textAlign ?? TextAlign.center,
            onEditingComplete: () {
              _controller.text = (widget.onEditingComplete?.call() ?? null) ??
                  _controller.text;
              (widget.focusNode ?? _focusNode).unfocus();
              FocusScope.of(context).unfocus();
              widget.toast?.call();
            },
            onChanged: (value) {
              widget.onChanged?.call(value);
              _updateText();
            },
            onTapOutside: (details) {
              if ((widget.focusNode ?? _focusNode).hasFocus) {
                _controller.text =
                    (widget.onTapOutside?.call(details) ?? null) ??
                        _controller.text;
                FocusScope.of(context).unfocus();
                widget.toast?.call();
              }
            },
          ),
        ],
      );

  Widget _buildDynamicIcon() {
    _isFirstFocus = true;
    return Padding(
      padding: EdgeInsets.only(bottom: 6),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: _controller.text + '        ',
              style: Theme.of(context)
                  .textTheme
                  .body2!
                  .copyWith(color: Colors.transparent),
            ),
            WidgetSpan(
                child:
                    Icon(Icons.edit_rounded, color: Colors.black26, size: 14)),
          ],
        ),
      ),
    );
  }
}
