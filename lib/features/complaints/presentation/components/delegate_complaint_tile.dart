import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateComplaintTile extends StatelessWidget {
  const DelegateComplaintTile({
    super.key,
    required this.complaint,
    required this.onOpen,
  });

  final Complaint complaint;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final category = complaint.departmentLabel ?? complaint.aiCategory;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h(context)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onOpen,
          borderRadius: BorderRadius.circular(16.r(context)),
          child: Container(
            padding: EdgeInsets.all(16.s(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r(context)),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  complaint.displayTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.f(context),
                  ),
                ),
                if (category != null && category.isNotEmpty) ...[
                  SizedBox(height: 4.h(context)),
                  Text(
                    category,
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 13.f(context),
                    ),
                  ),
                ],
                if (complaint.cardLocationDisplay != null) ...[
                  SizedBox(height: 4.h(context)),
                  Text(
                    complaint.cardLocationDisplay!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.f(context),
                    ),
                  ),
                ],
                if (complaint.imageAttachments.isNotEmpty) ...[
                  SizedBox(height: 8.h(context)),
                  Text(
                    '${complaint.imageAttachments.length} صورة مرفقة',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.f(context),
                    ),
                  ),
                ],
                if (complaint.fieldOutcomeLabel != null) ...[
                  SizedBox(height: 4.h(context)),
                  Text(
                    'آخر نتيجة: ${complaint.fieldOutcomeLabel}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.f(context),
                    ),
                  ),
                ],
                SizedBox(height: 12.h(context)),
                ElevatedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.visibility_outlined, color: Colors.white),
                  label: const Text(
                    'عرض التفاصيل والموقع',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
