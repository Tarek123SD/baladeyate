import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Stylish password field: a single connected box with the visibility toggle
/// on the left, separated from the input by a vertical divider line. The toggle
/// area stays clear (no fill color) while the input area is filled.
/// Used across login and signup for both citizen and delegate flows.
class PasswordInputField extends StatefulWidget {
  const PasswordInputField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggle,
    this.validator,
    this.hint = '••••••••',
  });

  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggle;
  final String? Function(String?)? validator;
  final String hint;

  @override
  State<PasswordInputField> createState() => _PasswordInputFieldState();
}

class _PasswordInputFieldState extends State<PasswordInputField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() => setState(() {});

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = 14.r(context);

    return FormField<String>(
      initialValue: widget.controller.text,
      validator: widget.validator,
      builder: (field) {
        final hasError = field.errorText != null;
        final borderColor = hasError
            ? AppColors.alertRed
            : (_focusNode.hasFocus
                ? AppColors.inputFocusedBorder
                : AppColors.inputBorder);
        final borderWidth = (_focusNode.hasFocus || hasError) ? 1.8 : 1.4;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(radius),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              // Painted over the child so the border (and focus color) stays visible.
              foregroundDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: borderColor, width: borderWidth),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Toggle area stays white (no fill color behind the eye).
                      Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: widget.onToggle,
                          child: Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 14.w(context)),
                            child: Icon(
                              widget.isVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.secondaryCharcoal,
                              size: 22.s(context),
                            ),
                          ),
                        ),
                      ),
                      Container(width: 1.4, color: AppColors.inputBorder),
                      // Filled input area.
                      Expanded(
                        child: ColoredBox(
                          color: AppColors.inputFill,
                          child: TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            textDirection: TextDirection.rtl,
                            obscureText: !widget.isVisible,
                            cursorColor: AppColors.secondaryForest,
                            onChanged: field.didChange,
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.f(context),
                              fontWeight: FontWeight.w500,
                              letterSpacing: 1.2,
                            ),
                            scrollPadding:
                                const EdgeInsets.only(bottom: 120),
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: widget.hint,
                              hintStyle: TextStyle(
                                color: Colors.grey[500],
                                letterSpacing: 1.2,
                              ),
                              hintTextDirection: TextDirection.rtl,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w(context),
                                vertical: 18.h(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: EdgeInsets.only(
                  top: 6.h(context),
                  right: 12.w(context),
                ),
                child: Text(
                  field.errorText!,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: AppColors.alertRed,
                    fontSize: 12.f(context),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
