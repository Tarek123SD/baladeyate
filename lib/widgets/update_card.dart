import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class UpdateCard extends StatelessWidget {
  const UpdateCard({
    super.key,
    required this.title,
    required this.time,
    required this.description,
    required this.icon,
    required this.iconBgColor,
  });

  final String title;
  final String time;
  final String description;
  final IconData icon;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    final r = 12.r(context);
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 0.5,
        ),
        color: Colors.white,
        borderRadius: BorderRadius.circular(r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8.r(context),
            offset: Offset(0, 2.s(context)),
          ),
        ],
      ),
      padding: EdgeInsets.all(16.s(context)),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Container(
            width: 50.s(context),
            height: 50.s(context),
            decoration: BoxDecoration(
              color: iconBgColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r(context)),
            ),
            child: Icon(
              icon,
              color: iconBgColor,
              size: 24.s(context),
            ),
          ),
          SizedBox(width: 16.s(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.s(context),
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12.s(context),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                SizedBox(height: 6.h(context)),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.s(context),
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                  textDirection: TextDirection.rtl,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
