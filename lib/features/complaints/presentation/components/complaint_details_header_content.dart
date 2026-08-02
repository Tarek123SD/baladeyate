import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

/// Header content (title, status, ticket id, date, tags) for complaint details.
class ComplaintDetailsHeaderContent extends StatelessWidget {
  const ComplaintDetailsHeaderContent({
    super.key,
    required this.complaint,
  });

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                complaint.displayTitle,
                style: TextStyle(
                  fontSize: 18.f(context),
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(width: 10.w(context)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10.w(context),
                vertical: 6.h(context),
              ),
              decoration: BoxDecoration(
                color: complaint.statusBackground,
                borderRadius: BorderRadius.circular(8.r(context)),
              ),
              child: Text(
                complaint.statusText,
                style: TextStyle(
                  color: complaint.statusForeground,
                  fontSize: 12.f(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Divider(color: Colors.grey.shade200, height: 1),
        SizedBox(height: 12.h(context)),
        Row(
          children: [
            Text(
              '#${complaint.id}',
              style: TextStyle(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14.f(context),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14.f(context),
              ),
            ),
            Text(
              complaint.formattedDate,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13.f(context),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h(context)),
        Wrap(
          spacing: 8.w(context),
          runSpacing: 6.h(context),
          children: [
            if (complaint.priority == 'urgent')
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(6.r(context)),
                ),
                child: Text(
                  'طارئ',
                  style: TextStyle(
                    color: const Color(0xFFC62828),
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else if (complaint.priorityText.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: complaint.priorityColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6.r(context)),
                ),
                child: Text(
                  complaint.priorityText,
                  style: TextStyle(
                    color: complaint.priorityColor,
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (complaint.aiCategory != null &&
                complaint.aiCategory!.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 8.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(6.r(context)),
                ),
                child: Text(
                  complaint.aiCategory!,
                  style: TextStyle(
                    color: const Color(0xFF2E7D32),
                    fontSize: 11.f(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
