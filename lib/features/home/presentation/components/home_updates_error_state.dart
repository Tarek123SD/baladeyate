import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeUpdatesErrorState extends StatelessWidget {
  const HomeUpdatesErrorState({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h(context)),
      child: Container(
        padding: EdgeInsets.all(20.s(context)),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16.r(context)),
          border: Border.all(
            color: Colors.red.withValues(alpha: 0.2),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 44.ic(context),
            ),
            SizedBox(height: 12.h(context)),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.f(context),
                fontWeight: FontWeight.w500,
                color: Colors.red[700],
              ),
              textDirection: TextDirection.rtl,
            ),
            SizedBox(height: 12.h(context)),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 16.s(context),
                  vertical: 8.h(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r(context)),
                ),
              ),
              icon: Icon(Icons.refresh_rounded, size: 16.ic(context)),
              label: Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 12.f(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
