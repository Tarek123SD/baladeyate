import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter/material.dart';

Future<String?> showSettingsPhoneUpdateDialog(
  BuildContext context,
  User user,
) async {
  final controller = TextEditingController(text: user.phoneNumber ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('تحديث رقم الهاتف'),
      content: TextField(
        controller: controller,
        keyboardType: TextInputType.phone,
        decoration: const InputDecoration(labelText: 'رقم الهاتف'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('إلغاء'),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(dialogContext, controller.text.trim()),
          child: const Text('حفظ'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}
