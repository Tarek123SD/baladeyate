import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.bgColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final Color? bgColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16.r(context)),
            border: Border.all(
              color: Colors.black,
              width: 0.5,
            ),
          ),
          padding: EdgeInsets.symmetric(vertical: 20.s(context)),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32.s(context),
                color: iconColor,
              ),
              SizedBox(height: 12.s(context)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.s(context),
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
