import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintDetailsSectionCard extends StatelessWidget {
  const ComplaintDetailsSectionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.bodyHeight = 1.5,
  });

  final IconData icon;
  final String title;
  final String body;
  final double bodyHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 18.ic(context),
              color: Colors.grey.shade800,
            ),
            SizedBox(width: 8.w(context)),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.f(context),
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h(context)),
        Text(
          body,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 14.f(context),
            height: bodyHeight,
          ),
        ),
      ],
    );
  }
}
