import 'package:cracte/src/common/common.dart';
import 'package:flutter/material.dart';
import 'package:reactive_forms/reactive_forms.dart';

class CustomReactiveDropdownField<T> extends StatefulWidget {
  final String? hintText;
  final bool autoFocus;
  final Widget? suffix;
  final Widget? prefix;
  final double borderRadius;
  final Map<String, String> validationMessages;
  final FormControl<dynamic>? formControl;
  final String? name;
  final FocusNode? focusNode;
  final bool busy;
  final bool _noLabel;
  final bool showError;
  final String? prefixText;
  final String? suffixText;
  final bool filled;
  final List<DropdownMenuItem<T>> items;
  final void Function(FormControl<T>)? onChanged;
  final ControlValueAccessor<T, String>? valueAccessor;
  final T? value;

  const CustomReactiveDropdownField({
    required this.name,
    this.autoFocus = false,
    this.hintText,
    this.suffix,
    this.prefix,
    this.formControl,
    this.validationMessages = const {},
    this.borderRadius = 16.0,
    this.focusNode,
    this.valueAccessor,
    this.busy = false,
    this.showError = true,
    super.key,
    this.prefixText,
    this.suffixText,
    this.filled = false,
    required this.items,
    this.onChanged,
    this.value,
  }) : _noLabel = false;

  const CustomReactiveDropdownField.noLabel({
    super.key,
    required this.name,
    this.autoFocus = false,
    this.suffix,
    this.prefix,
    this.formControl,
    this.validationMessages = const {},
    this.borderRadius = 16.0,
    this.focusNode,
    this.valueAccessor,
    this.busy = false,
    this.showError = true,
    this.prefixText,
    this.suffixText,
    this.filled = false,
    required this.items,
    this.onChanged,
    this.value,
  })  : _noLabel = true,
        hintText = null;

  @override
  State<CustomReactiveDropdownField<T>> createState() =>
      _CustomReactiveDropdownFieldState<T>();
}

class _CustomReactiveDropdownFieldState<T>
    extends State<CustomReactiveDropdownField<T>> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDropdownField();
  }

  Widget _buildDropdownField() {
    final validationMessages = {
      ValidationMessage.required: (_) {
        return 'Cannot be empty';
      },
    };

    final manualValidationMessages = widget.validationMessages.map((
      key,
      value,
    ) {
      return MapEntry(key, (_) => value);
    });

    validationMessages.addAll(manualValidationMessages);
    final isDisabled = context.isFormDisabled(widget.name!);

    return AnimatedBuilder(
      animation: _focusNode,
      builder: (_, __) {
        final isFocused = _focusNode.hasFocus;
        final Color valueColor =
            isDisabled ? Colors.grey : context.textTheme.bodyLarge!.color!;

        final iconColor = isFocused ? Colors.blueGrey : valueColor;

        final double verticalPadding = context.isMobile ? 9.0 : 12.5;

        return ReactiveDropdownField<T>(
          focusNode: _focusNode,
          formControl: widget.formControl as FormControl<T>?,
          formControlName: widget.name,
          validationMessages: validationMessages,
          autofocus: widget.autoFocus,
          onChanged: widget.onChanged,
          items: widget.items,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.isDarkMode ? Colors.white : Colors.grey.shade900,
          ),
          decoration: InputDecoration(
            prefixText: widget.prefixText,
            hoverColor: Colors.transparent,
            fillColor: Colors.grey.withValues(alpha: 0.06),
            filled: widget.filled,
            errorMaxLines: 2,
            contentPadding: widget._noLabel
                ? null
                : EdgeInsets.symmetric(
                    horizontal: 12.0,
                    vertical: verticalPadding,
                  ),
            counterStyle: const TextStyle(height: double.minPositive),
            counterText: '',
            suffixIcon: widget.suffix != null
                ? IconTheme(
                    data: IconThemeData(color: iconColor),
                    child: widget.suffix!,
                  )
                : null,
            prefixIcon: widget.prefix != null
                ? IconTheme(
                    data: IconThemeData(color: iconColor),
                    child: widget.prefix!,
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: BorderSide(color: context.theme.primaryColor),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              borderSide: const BorderSide(color: Colors.red),
            ),
            hintText: widget.hintText ?? widget.name,
            hintStyle: context.textTheme.bodySmall?.copyWith(
              color: Colors.grey.shade500,
            ),
            floatingLabelBehavior: FloatingLabelBehavior.auto,
          ),
          showErrors: (control) =>
              widget.showError &&
              control.invalid &&
              (control.dirty || control.touched),
          icon: widget.busy
              ? const SizedBox(
                  width: 20.0,
                  height: 20.0,
                  child: CircularProgressIndicator(strokeWidth: 2.0),
                )
              : const Icon(Icons.arrow_drop_down),
          dropdownColor: context.theme.scaffoldBackgroundColor,
          isExpanded: true,
        );
      },
    );
  }
}
