import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DigitalDocumentsLoadingState extends StatelessWidget {
  const DigitalDocumentsLoadingState({super.key});

  static const Color primaryDarkGreen = Color(0xFF1B5E20);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: primaryDarkGreen,
          ),
          SizedBox(height: 14.h(context)),
          Text(
            'جاري تحميل الوثائق الرقمية...',
            style: TextStyle(
              fontSize: 13.f(context),
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
