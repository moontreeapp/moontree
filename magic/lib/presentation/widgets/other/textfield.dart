import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/extensions.dart';

class TextFieldFormatted extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final TextStyle? focusStyle;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final bool? showCursor;
  final bool autofocus;
  final String obscuringCharacter;
  final bool obscureText;
  final bool autocorrect;
  final SmartDashesType? smartDashesType;
  final SmartQuotesType? smartQuotesType;
  final bool enableSuggestions;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final int? maxLength;
  final bool maxLengthEnforced;
  final MaxLengthEnforcement? maxLengthEnforcement;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final void Function(String)? onSubmitted;
  final List<TextInputFormatter>? inputFormatters;
  final bool? enabled;
  final double cursorWidth;
  final double? cursorHeight;
  final Radius? cursorRadius;
  final Color? cursorColor;
  final ui.BoxHeightStyle selectionHeightStyle;
  final ui.BoxWidthStyle selectionWidthStyle;
  final Brightness? keyboardAppearance;
  final EdgeInsets scrollPadding;
  final DragStartBehavior dragStartBehavior;
  final bool enableInteractiveSelection;
  final TextSelectionControls? selectionControls;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  final MouseCursor? mouseCursor;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final Iterable<String>? autofillHints;
  final Clip clipBehavior;
  final String? restorationId;
  final bool enableIMEPersonalizedLearning;
  final InputBorder? border;
  final InputBorder? focusedErrorBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedBorder;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final EdgeInsetsGeometry? contentPadding;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final Widget? suffixIcon;
  final String? suffixText;
  final Widget? prefixIcon;
  final TextStyle? helperStyle;
  final TextStyle? suffixStyle;
  final bool alwaysShowHelper;
  final int? helperMaxLines;
  final double contentPaddingTop;
  final double contentPaddingLeft;

  const TextFieldFormatted({
    super.key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.suffixText,
    this.prefixIcon,
    this.helperStyle,
    this.suffixStyle,
    this.helperMaxLines,
    this.alwaysShowHelper = false,
    this.controller,
    this.focusNode,
    this.decoration = const InputDecoration(),
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.style,
    this.focusStyle,
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.showCursor,
    this.autofocus = false,
    this.obscuringCharacter = '•',
    this.obscureText = false,
    this.autocorrect = true,
    this.smartDashesType,
    this.smartQuotesType,
    this.enableSuggestions = true,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.maxLength,
    this.maxLengthEnforced = true,
    this.maxLengthEnforcement,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.inputFormatters,
    this.enabled,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.cursorColor,
    this.selectionHeightStyle = ui.BoxHeightStyle.tight,
    this.selectionWidthStyle = ui.BoxWidthStyle.tight,
    this.keyboardAppearance,
    this.scrollPadding = const EdgeInsets.all(20.0),
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.selectionControls,
    this.onTap,
    this.onTapOutside,
    this.mouseCursor,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.focusedErrorBorder,
    this.errorBorder,
    this.focusedBorder,
    this.enabledBorder,
    this.disabledBorder,
    this.border,
    this.contentPadding,
    this.contentPaddingTop = 0.0,
    this.contentPaddingLeft = 0.0,
  });

  @override
  State<TextFieldFormatted> createState() => _TextFieldFormattedState();
}

class _TextFieldFormattedState extends State<TextFieldFormatted> {
  bool get inUse => widget.focusNode?.hasFocus ?? false;
  bool get used => widget.controller?.text != '';

  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = widget.border != null
        ? InputDecoration(
            border: widget.border,
            prefixIcon: widget.prefixIcon,
          )
        : InputDecoration(
            enabled: widget.enabled ?? true,
            prefixIcon: widget.prefixIcon,
            //floatingLabelGap: -2,
            //filled: false,
            //fillColor: Colors.transparent,
            //focusColor: Colors.transparent,
            border: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            labelStyle: Theme.of(context).textTheme.sub1.copyWith(
                color: (widget.enabled ?? true) ? null : AppColors.black60),
            alignLabelWithHint: true,
            floatingLabelStyle: inUse
                ? const TextStyle(color: AppColors.primary)
                : const TextStyle(color: AppColors.black87),
            contentPadding: EdgeInsets.only(
              left: 24 + widget.contentPaddingLeft,
              top: (inUse || used ? 16 : 12) +
                  widget.contentPaddingTop, // 14, 10 if floatingLabelGap: 0
              right: 14,
              bottom: inUse || used ? 16 : 20, // 20, 24 alternative
            ),
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.alwaysShowHelper
                ? widget.helperText
                : widget.focusNode?.hasFocus ?? true
                    ? widget.helperText
                    : null,
            helperMaxLines: widget.helperMaxLines,
            // takes precedence -- only fill on field valdiation failure:
            errorText: widget.errorText,
            suffixIcon: widget.suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 20, top: 10),
                    child: widget.suffixIcon)
                : null,
            suffixText: widget.suffixText,
            suffixStyle: widget.suffixStyle,
            errorStyle: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(height: .8, color: AppColors.error),
            helperStyle: widget.helperStyle ??
                Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(height: .8, color: AppColors.primary),
          );
    final TextField text = TextField(
        //key: widget.key,
        decoration: decoration,
        onTap: widget.onTap ?? () => setState(() {}), // solves #594
        onTapOutside: widget.onTapOutside ??
            (_) {
              (widget.focusNode ?? FocusScope.of(context)).unfocus();
              setState(() {});
            },
        //onTapOutside: (_) => FocusScope.of(context).unfocus(),
        //onTapOutside: (_) => widget.cubit.reset(),
        style: widget.focusStyle == null
            ? widget.style
            : inUse
                ? widget.focusStyle
                : widget.style,
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        readOnly: widget.readOnly,
        //toolbarOptions: widget.toolbarOptions, //contextMenuBuilder
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        obscuringCharacter: widget.obscuringCharacter,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        expands: widget.expands,
        maxLength: widget.maxLength,
        maxLengthEnforcement: widget.maxLengthEnforcement,
        onChanged: widget.onChanged,
        onEditingComplete: widget.onEditingComplete,
        onSubmitted: widget.onSubmitted,
        inputFormatters: widget.inputFormatters,
        enabled: widget.enabled,
        cursorWidth: widget.cursorWidth,
        cursorHeight: widget.cursorHeight,
        cursorRadius: widget.cursorRadius,
        cursorColor: widget.cursorColor,
        selectionHeightStyle: widget.selectionHeightStyle,
        selectionWidthStyle: widget.selectionWidthStyle,
        keyboardAppearance: widget.keyboardAppearance,
        scrollPadding: widget.scrollPadding,
        dragStartBehavior: widget.dragStartBehavior,
        enableInteractiveSelection: widget.enableInteractiveSelection,
        selectionControls: widget.selectionControls,
        mouseCursor: widget.mouseCursor,
        scrollController: widget.scrollController,
        scrollPhysics: widget.scrollPhysics,
        autofillHints: widget.autofillHints,
        clipBehavior: widget.clipBehavior,
        restorationId: widget.restorationId,
        enableIMEPersonalizedLearning: widget.enableIMEPersonalizedLearning);
    return Stack(children: [
      Column(children: [
        const SizedBox(height: 12),
        Container(
          height: 64,
          decoration: ShapeDecoration(
            //color: Color(0xFFE8EAF6),
            //color: Colors.white,
            //color: AppColors.black60,
            color: const Color(0xFFE5E5E5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28 * 100),
            ),
          ),
        )
      ]),
      //ClipRRect(
      //    borderRadius: BorderRadius.circular(28 * 100),
      //    child: )
      widget.controller != null
          ? GestureDetector(
              onDoubleTap: () async => widget.controller?.text =
                  (await Clipboard.getData('text/plain'))?.text ?? '',
              child: text)
          : text
    ]);
  }
}
