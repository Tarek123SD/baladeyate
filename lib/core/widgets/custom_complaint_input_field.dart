import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomComplaintInputField extends StatefulWidget {
  const CustomComplaintInputField({
    super.key,
    required this.hint,
    this.maxLines = 1,
    this.controller,
    this.prefixIcon,
    this.keyboardType,
    this.onChanged,
  });

  final String hint;
  final int maxLines;
  final TextEditingController? controller;
  final IconData? prefixIcon;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  State<CustomComplaintInputField> createState() =>
      _CustomComplaintInputFieldState();
}

class _CustomComplaintInputFieldState extends State<CustomComplaintInputField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14.r(context));

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius,
        border: Border.all(
          color: _isFocused
              ? AppColors.thirdForest
              : AppColors.primaryForest.withValues(alpha: 0.12),
          width: _isFocused ? 1.6 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isFocused
                ? AppColors.thirdForest.withValues(alpha: 0.18)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: _isFocused ? 14 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        onChanged: widget.onChanged,
        maxLines: widget.maxLines,
        keyboardType: widget.keyboardType ??
            (widget.maxLines > 1 ? TextInputType.multiline : TextInputType.text),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
        cursorColor: AppColors.thirdForest,
        style: TextStyle(
          fontSize: 14.f(context),
          color: AppColors.primaryCharcoal,
          height: 1.5,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            fontSize: 13.f(context),
            color: AppColors.secondaryCharcoal.withValues(alpha: 0.55),
          ),
          filled: false,
          isDense: true,
          suffixIcon: widget.prefixIcon == null
              ? null
              : Padding(
                  padding: EdgeInsets.only(left: 4.s(context)),
                  child: Icon(
                    widget.prefixIcon,
                    size: 20.ic(context),
                    color: _isFocused
                        ? AppColors.thirdForest
                        : AppColors.primaryForest.withValues(alpha: 0.55),
                  ),
                ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.s(context),
            vertical: 15.s(context),
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
