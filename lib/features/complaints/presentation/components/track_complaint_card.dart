import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintCard extends StatelessWidget {
  const TrackComplaintCard({
    super.key,
    required this.complaint,
    required this.onTap,
  });

  final Complaint complaint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16.r(context)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r(context)),
          child: Padding(
            padding: EdgeInsets.all(16.s(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.displayTitle,
                        style: TextStyle(
                          fontSize: 15.f(context),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w(context)),
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
                SizedBox(height: 8.h(context)),
                Row(
                  children: [
                    Text(
                      '#${complaint.id}',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.f(context),
                      ),
                    ),
                    Text(
                      ' • ',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 13.f(context),
                      ),
                    ),
                    Text(
                      complaint.formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13.f(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h(context)),
                Text(
                  complaint.description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.f(context),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h(context)),
                Divider(
                  color: Colors.grey.shade200,
                  height: 1,
                  thickness: 1,
                ),
                SizedBox(height: 12.h(context)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (complaint.priority == 'urgent')
                          Padding(
                            padding: EdgeInsets.only(left: 6.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w(context),
                                vertical: 4.h(context),
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFEBEE),
                                borderRadius:
                                    BorderRadius.circular(6.r(context)),
                              ),
                              child: Text(
                                'طارئ',
                                style: TextStyle(
                                  color: const Color(0xFFC62828),
                                  fontSize: 11.f(context),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          )
                        else if (complaint.priorityText.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(left: 6.w(context)),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8.w(context),
                                vertical: 4.h(context),
                              ),
                              decoration: BoxDecoration(
                                color: complaint.priorityColor
                                    .withValues(alpha: 0.12),
                                borderRadius:
                                    BorderRadius.circular(6.r(context)),
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
                              borderRadius:
                                  BorderRadius.circular(6.r(context)),
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
                    InkWell(
                      onTap: onTap,
                      borderRadius: BorderRadius.circular(4.r(context)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'التفاصيل',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.f(context),
                            ),
                          ),
                          SizedBox(width: 2.w(context)),
                          Icon(
                            Icons.chevron_left,
                            color: primaryColor,
                            size: 20.ic(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
