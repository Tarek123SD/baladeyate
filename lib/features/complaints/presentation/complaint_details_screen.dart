import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_cubit.dart';
import 'package:baladeyate/features/complaints/cubits/complaint_detail_cubit/complaint_detail_state.dart';
import 'package:baladeyate/features/complaints/models/complaint.dart';
import 'package:baladeyate/features/complaints/models/complaint_description.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_header_content.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_info_card.dart';
import 'package:baladeyate/features/complaints/presentation/components/complaint_details_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class ComplaintDetailsScreen extends StatelessWidget {
  const ComplaintDetailsScreen({
    super.key,
    required this.complaint,
  });

  final Complaint complaint;

  @override
  Widget build(BuildContext context) {
    final complaintDetailCubit = _tryRead<ComplaintDetailCubit>(context);

    if (complaintDetailCubit != null) {
      return BlocBuilder<ComplaintDetailCubit, ComplaintDetailState>(
        builder: (context, state) {
          return _buildScreen(context, state.complaint);
        },
      );
    }

    return _buildScreen(context, complaint);
  }

  static T? _tryRead<T extends StateStreamableSource<Object?>>(
      BuildContext context) {
    try {
      return context.read<T>();
    } catch (_) {
      return null;
    }
  }

  Widget _buildScreen(BuildContext context, Complaint targetComplaint) {
    final parts = parseComplaintDescription(targetComplaint.description);
    final locationDisplay = targetComplaint.cardLocationDisplay;
    final detailCubit = _tryRead<ComplaintDetailCubit>(context);

    final descriptionBody = parts.details.isNotEmpty
        ? parts.details
        : (parts.subject.isNotEmpty
            ? parts.subject
            : targetComplaint.description);

    final content = SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.all(16.s(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ComplaintDetailsInfoCard(
            children: [
              ComplaintDetailsHeaderContent(complaint: targetComplaint),
            ],
          ),
          ComplaintDetailsInfoCard(
            children: [
              ComplaintDetailsSectionCard(
                icon: Icons.description_outlined,
                title: 'نص الشكوى',
                body: descriptionBody,
              ),
            ],
          ),
          if (locationDisplay != null && locationDisplay.isNotEmpty)
            ComplaintDetailsInfoCard(
              children: [
                ComplaintDetailsSectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'الموقع',
                  body: locationDisplay,
                  bodyHeight: 1.4,
                ),
              ],
            ),
          if (targetComplaint.attachments.isNotEmpty)
            ComplaintDetailsInfoCard(
              children: [
                ComplaintDetailsSectionCard(
                  icon: Icons.photo_library_outlined,
                  title: 'المرفقات',
                  body: '${targetComplaint.attachments.length} مرفق',
                  bodyHeight: 1.4,
                ),
                SizedBox(height: 12.s(context)),
                Wrap(
                  spacing: 10.s(context),
                  runSpacing: 10.s(context),
                  children: [
                    for (final url in targetComplaint.attachments)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r(context)),
                        child: Image.network(
                          url,
                          width: 96.s(context),
                          height: 96.s(context),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 96.s(context),
                              height: 96.s(context),
                              color: Colors.grey.shade200,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: Colors.grey.shade600,
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: Text(
            'تفاصيل الشكوى',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 18.f(context),
            ),
          ),
          centerTitle: true,
        ),
        body: detailCubit != null
            ? RefreshIndicator(
                color: AppColors.primaryForest,
                onRefresh: detailCubit.loadDetail,
                child: content,
              )
            : content,
      ),
    );
  }
}
