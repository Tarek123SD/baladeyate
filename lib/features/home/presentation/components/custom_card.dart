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
    final radius = 16.r(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12.r(context),
                offset: Offset(0, 3.h(context)),
              ),
            ],
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 12.s(context),
            vertical: 18.s(context),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48.s(context),
                height: 48.s(context),
                decoration: BoxDecoration(
                  color: (iconColor ?? Colors.black).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 24.s(context),
                  color: iconColor,
                ),
              ),
              SizedBox(height: 10.s(context)),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
