import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsErrorSection extends StatelessWidget {
  const TransactionsErrorSection({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48.ic(context),
          color: AppColors.alertRed,
        ),
        SizedBox(height: 12.h(context)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.f(context),
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}
