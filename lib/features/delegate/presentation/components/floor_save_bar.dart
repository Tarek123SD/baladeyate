import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class FloorSaveBar extends StatelessWidget {
  const FloorSaveBar({
    super.key,
    required this.onSave,
  });

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w(context)),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: onSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryForest,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 14.h(context)),
          ),
          child: const Text('حفظ الطابق'),
        ),
      ),
    );
  }
}
