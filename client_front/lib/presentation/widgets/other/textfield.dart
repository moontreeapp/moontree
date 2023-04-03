import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:client_front/presentation/theme/colors.dart';
import 'package:client_back/services/services.dart';

class TextFieldFormatted extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final TextDirection? textDirection;
  final bool readOnly;
  final ToolbarOptions? toolbarOptions;
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
  final TextStyle? helperStyle;
  final TextStyle? suffixStyle;
  final bool alwaysShowHelper;
  final int? helperMaxLines;

  const TextFieldFormatted({
    Key? key,
    this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.suffixIcon,
    this.suffixText,
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
    this.strutStyle,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.textDirection,
    this.readOnly = false,
    this.toolbarOptions,
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
    this.mouseCursor,
    this.scrollController,
    this.scrollPhysics,
    this.autofillHints = const <String>[],
    this.clipBehavior = Clip.hardEdge,
    this.restorationId,
    this.enableIMEPersonalizedLearning = true,
    this.focusedErrorBorder = null,
    this.errorBorder = null,
    this.focusedBorder = null,
    this.enabledBorder = null,
    this.disabledBorder = null,
    this.border = null,
    this.contentPadding = null,
  }) : super(key: key);

  @override
  State<TextFieldFormatted> createState() => _TextFieldFormattedState();
}

class _TextFieldFormattedState extends State<TextFieldFormatted> {
  @override
  Widget build(BuildContext context) {
    final InputDecoration decoration = widget.border != null
        ? InputDecoration(
            border: widget.border,
          )
        : InputDecoration(
            focusedErrorBorder: widget.focusedErrorBorder ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 2)),
            errorBorder: widget.errorBorder ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: AppColors.error, width: 2)),
            focusedBorder: widget.focusedBorder ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2)),
            enabledBorder: widget.enabledBorder ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.black12)),
            disabledBorder: widget.disabledBorder ??
                OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: const BorderSide(color: AppColors.black12)),
            labelStyle: Theme.of(context).textTheme.subtitle1!.copyWith(
                color: (widget.enabled ?? true) ? null : AppColors.black38),
            alignLabelWithHint: true,
            floatingLabelStyle: widget.focusNode?.hasFocus ?? false
                ? TextStyle(
                    color: widget.errorText == null
                        ? AppColors.primary
                        : AppColors.error)
                : TextStyle(
                    color: widget.errorText == null
                        ? AppColors.black60
                        : AppColors.error),
            contentPadding: widget.contentPadding ??
                const EdgeInsets.only(left: 16.5, top: 18, bottom: 16),
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
            suffixIcon: widget.suffixIcon,
            suffixText: widget.suffixText,
            suffixStyle: widget.suffixStyle,
            errorStyle: Theme.of(context)
                .textTheme
                .caption!
                .copyWith(height: .8, color: AppColors.error),
            helperStyle: widget.helperStyle ??
                Theme.of(context)
                    .textTheme
                    .caption!
                    .copyWith(height: .8, color: AppColors.primary),
          );
    final TextField text = TextField(
        //key: widget.key,
        decoration: decoration,
        onTap: widget.onTap ?? () => setState(() {}), // solves #594
        controller: widget.controller,
        focusNode: widget.focusNode,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        textCapitalization: widget.textCapitalization,
        style: widget.style,
        strutStyle: widget.strutStyle,
        textAlign: widget.textAlign,
        textAlignVertical: widget.textAlignVertical,
        textDirection: widget.textDirection,
        readOnly: widget.readOnly,
        toolbarOptions: widget.toolbarOptions,
        showCursor: widget.showCursor,
        autofocus: widget.autofocus,
        obscuringCharacter: widget.obscuringCharacter,
        obscureText: widget.obscureText,
        autocorrect: widget.autocorrect,
        smartDashesType: widget.smartDashesType,
        smartQuotesType: widget.smartQuotesType,
        enableSuggestions: widget.enableSuggestions,
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
    return widget.controller != null && services.developer.developerMode
        ? GestureDetector(
            onDoubleTap: () async => widget.controller?.text =
                (await Clipboard.getData('text/plain'))?.text ?? '',
            child: text)
        : text;
  }
}
