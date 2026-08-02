import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:flutter/material.dart';

/// Result returned when the user confirms adding a grave.
class AddGraveDialogResult {
  const AddGraveDialogResult({
    required this.status,
    this.deceasedName,
  });

  final String status;
  final String? deceasedName;
}

/// Dialog to choose status (and deceased name when occupied) for a new grave.
class AddGraveDialog extends StatefulWidget {
  const AddGraveDialog({
    super.key,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  @override
  State<AddGraveDialog> createState() => _AddGraveDialogState();
}

class _AddGraveDialogState extends State<AddGraveDialog> {
  final _formKey = GlobalKey<FormState>();
  final _deceasedNameController = TextEditingController();

  String _status = 'available';

  static InputDecoration _fieldDecoration({
    String? hintText,
    Widget? prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: AppColors.secondaryCharcoal.withValues(alpha: 0.45),
      ),
      prefixIcon: prefixIcon,
      filled: true,
      fillColor: AppColors.thirdGoldenWheat.withValues(alpha: 0.35),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryForest.withValues(alpha: 0.15),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: AppColors.primaryForest.withValues(alpha: 0.15),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: AppColors.primaryForest,
          width: 1.6,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.alertRed),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.alertRed, width: 1.6),
      ),
    );
  }

  @override
  void dispose() {
    _deceasedNameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final deceasedName =
        _status == 'occupied' ? _deceasedNameController.text.trim() : null;

    Navigator.of(context).pop(
      AddGraveDialogResult(
        status: _status,
        deceasedName: deceasedName?.isEmpty == true ? null : deceasedName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 10,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primaryForest.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          AppIcons.addLocation,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إضافة قبر جديد',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryForest,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'الموقع: (${widget.x.toStringAsFixed(0)}, '
                              '${widget.y.toStringAsFixed(0)}) · '
                              '${widget.width.toInt()}×${widget.height.toInt()}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.secondaryCharcoal
                                    .withValues(alpha: 0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'حالة القبر',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryCharcoal,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: _fieldDecoration(
                      prefixIcon: Icon(
                        _status == 'occupied'
                            ? Icons.person_off_outlined
                            : Icons.check_circle_outline,
                        color: AppColors.primaryForest,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(14),
                    dropdownColor: AppColors.surfaceWhite,
                    iconEnabledColor: AppColors.primaryForest,
                    style: const TextStyle(
                      color: AppColors.primaryCharcoal,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'available',
                        child: Text('متاح'),
                      ),
                      DropdownMenuItem(
                        value: 'occupied',
                        child: Text('مشغول'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _status = value);
                    },
                  ),
                  if (_status == 'occupied') ...[
                    const SizedBox(height: 16),
                    Text(
                      'اسم المتوفى',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryCharcoal,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _deceasedNameController,
                      textDirection: TextDirection.rtl,
                      textInputAction: TextInputAction.done,
                      style: const TextStyle(
                        color: AppColors.primaryCharcoal,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: _fieldDecoration(
                        hintText: 'أدخل اسم المتوفى',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.primaryForest,
                        ),
                      ),
                      validator: (value) {
                        if (_status != 'occupied') return null;
                        if (value == null || value.trim().isEmpty) {
                          return 'اسم المتوفى مطلوب للقبر المشغول';
                        }
                        return null;
                      },
                      onFieldSubmitted: (_) => _submit(),
                    ),
                  ],
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          onPressed: _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primaryForest,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'تأكيد',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondaryCharcoal,
                            side: BorderSide(
                              color: AppColors.primaryForest
                                  .withValues(alpha: 0.25),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'إلغاء',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
