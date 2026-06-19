import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';
import 'package:baladeyate/config/theme/app_colors.dart';

/// Reusable form dropdown field with RTL support.
class FormDropdownField extends StatelessWidget {
  const FormDropdownField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.prefixIcon,
    this.enabled = true,
  });

  /// Field label
  final String label;

  /// List of dropdown items
  final List<String> items;

  /// Current selected value
  final String? value;

  /// On change callback
  final Function(String?)? onChanged;

  /// Prefix icon
  final IconData? prefixIcon;

  /// Whether the field is enabled
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          label,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 13.s(context),
            fontWeight: FontWeight.w600,
            color: AppColors.secondaryCharcoal,
          ),
        ),
        SizedBox(height: 10.h(context)),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r(context)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonFormField<String>(
            key: ValueKey(value),
            initialValue: value,
            onChanged: enabled ? onChanged : null,
            items: items
                .map(
                  (String item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                )
                .toList(),
            decoration: InputDecoration(
              hintText: 'اختر...',
              hintTextDirection: TextDirection.rtl,
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.s(context),
              ),
              filled: true,
              fillColor: enabled ? Colors.white : Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: const BorderSide(
                  color: Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r(context)),
                borderSide: BorderSide(
                  color: AppColors.primaryForest,
                  width: 2,
                ),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(
                      prefixIcon,
                      color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
                      size: 20.s(context),
                    )
                  : null,
              suffixIcon: Icon(
                Icons.expand_more_rounded,
                color: AppColors.secondaryCharcoal.withValues(alpha: 0.6),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w(context),
                vertical: 14.h(context),
              ),
            ),
            isExpanded: true,
            dropdownColor: Colors.white,
            style: TextStyle(
              fontSize: 14.s(context),
              color: AppColors.secondaryCharcoal,
            ),
          ),
        ),
      ],
    );
  }
}
