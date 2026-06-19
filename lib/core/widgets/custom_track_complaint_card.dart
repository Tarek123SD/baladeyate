import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomTrackComplaintCard extends StatelessWidget {
  const CustomTrackComplaintCard({
    super.key,
    required this.complaint,
    this.onTap,
  });

  final Map<String, dynamic> complaint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r(context)),
        child: Ink(
          padding: EdgeInsets.all(18.s(context)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r(context)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.06),
                blurRadius: 18,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                fit: FlexFit.loose,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w(context),
                    vertical: 8.h(context),
                  ),
                  decoration: BoxDecoration(
                    color: complaint['statusColor'] as Color,
                    borderRadius: BorderRadius.circular(14.r(context)),
                  ),
                  child: Text(
                    complaint['statusLabel'] as String,
                    style: TextStyle(
                      fontSize: 12.f(context),
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              SizedBox(width: 10.w(context)),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(
                      complaint['icon'] as IconData,
                      color: AppColors.primaryForest,
                      size: 22.ic(context),
                    ),
                    SizedBox(width: 10.w(context)),
                    Flexible(
                      child: Text(
                        complaint['title'] as String,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h(context)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                complaint['date'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF777777),
                    ),
              ),
              Text(
                complaint['request'] as String,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF777777),
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          SizedBox(height: 12.h(context)),
          Text(
            complaint['description'] as String,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.6,
                  color: const Color(0xFF4D4D4D),
                ),
          ),
          SizedBox(height: 18.h(context)),
          LayoutBuilder(
            builder: (context, constraints) {
              final actionChip = Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 14.w(context),
                  vertical: 10.h(context),
                ),
                decoration: BoxDecoration(
                  color: AppColors.thirdGoldenWheat,
                  borderRadius: BorderRadius.circular(18.r(context)),
                ),
                child: Text(
                  'تحديث الحالة',
                  style: TextStyle(
                    fontSize: 12.f(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );

              final tags = Wrap(
                spacing: 8.w(context),
                runSpacing: 8.h(context),
                children: (complaint['tags'] as List<dynamic>).map((tag) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w(context),
                      vertical: 8.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7F4EC),
                      borderRadius: BorderRadius.circular(16.r(context)),
                    ),
                    child: Text(
                      tag.toString(),
                      style: TextStyle(
                        fontSize: 12.f(context),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF235235),
                      ),
                    ),
                  );
                }).toList(),
              );

              if (constraints.maxWidth < 360.w(context)) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    actionChip,
                    SizedBox(height: 10.h(context)),
                    tags,
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: tags),
                  SizedBox(width: 12.w(context)),
                  actionChip,
                ],
              );
            },
          ),
        ],
          ),
        ),
      ),
    );
  }
}
