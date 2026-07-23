import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';

import '../cubits/digital_documents_cubit/digital_documents_cubit.dart';
import '../cubits/digital_documents_cubit/digital_documents_state.dart';
import '../models/digital_document_model.dart';
import 'widgets/digital_document_card.dart';
import 'widgets/digital_documents_empty_state.dart';

/// Screen UI for "Digital Documents" (الوثائق الرقمية) wallet.
class DigitalDocumentsScreen extends StatelessWidget {
  const DigitalDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      BlocProvider.of<DigitalDocumentsCubit>(context);
      return const DigitalDocumentsView();
    } catch (_) {
      return BlocProvider(
        create: (context) =>
            sl<DigitalDocumentsCubit>()..fetchDigitalDocuments(),
        child: const DigitalDocumentsView(),
      );
    }
  }
}

class DigitalDocumentsView extends StatefulWidget {
  const DigitalDocumentsView({super.key});

  @override
  State<DigitalDocumentsView> createState() => _DigitalDocumentsViewState();
}

class _DigitalDocumentsViewState extends State<DigitalDocumentsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DigitalDocumentsCubit>().fetchDigitalDocuments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    const primaryDarkGreen = Color(0xFF1B5E20);

    return BlocListener<DigitalDocumentsCubit, DigitalDocumentsState>(
      listener: (context, state) {
        if (state is DigitalDocumentsError) {
          AppSnackBar.showError(context, state.message);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA), // Very light grey / off-white
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'الوثائق الرقمية',
            style: TextStyle(
              fontSize: 18.f(context),
              fontWeight: FontWeight.bold,
              color: AppColors.primaryCharcoal,
            ),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20.ic(context),
              color: AppColors.primaryCharcoal,
            ),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 900.w(context)),
                child: RefreshIndicator(
                  color: primaryDarkGreen,
                  onRefresh: () => context
                      .read<DigitalDocumentsCubit>()
                      .fetchDigitalDocuments(),
                  child: BlocBuilder<DigitalDocumentsCubit,
                      DigitalDocumentsState>(
                    builder: (context, state) {
                      // 1. Loading State
                      if (state is DigitalDocumentsLoading) {
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

                      // 2. Error State
                      if (state is DigitalDocumentsError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(horizontalPadding),
                            child: _buildErrorWidget(
                              context,
                              message: state.message,
                              onRetry: () => context
                                  .read<DigitalDocumentsCubit>()
                                  .fetchDigitalDocuments(),
                            ),
                          ),
                        );
                      }

                      // 3. Success State
                      if (state is DigitalDocumentsSuccess) {
                        final documents = state.documents;

                        // Empty State
                        if (documents.isEmpty) {
                          return SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: DigitalDocumentsEmptyState(
                              onRefresh: () => context
                                  .read<DigitalDocumentsCubit>()
                                  .fetchDigitalDocuments(),
                              onSubmitNewTransaction: () =>
                                  context.push('/transactions/submit'),
                            ),
                          );
                        }

                        // ListView.builder of Digital Document Cards
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.all(horizontalPadding),
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            final document = documents[index];
                            return DigitalDocumentCard(
                              document: document,
                              cardIndex: index,
                              onTapDetails: () =>
                                  _showDocumentDetailsModal(context, document),
                            );
                          },
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom Modal Sheet for viewing complete details & enlarged QR code
  void _showDocumentDetailsModal(
    BuildContext context,
    DigitalDocumentModel document,
  ) {
    const primaryDarkGreen = Color(0xFF1B5E20);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r(context)),
              ),
            ),
            padding: EdgeInsets.all(20.s(context)),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40.w(context),
                      height: 4.h(context),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2.r(context)),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h(context)),

                  // Header Badge
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.s(context)),
                        decoration: BoxDecoration(
                          color: primaryDarkGreen.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.verified_rounded,
                          color: primaryDarkGreen,
                          size: 24.ic(context),
                        ),
                      ),
                      SizedBox(width: 12.w(context)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              document.translatedType,
                              style: TextStyle(
                                fontSize: 18.f(context),
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryCharcoal,
                              ),
                            ),
                            Text(
                              'وثيقة رقمية صادرة ومعتمدة رسمياً',
                              style: TextStyle(
                                fontSize: 12.f(context),
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h(context)),
                  const Divider(),
                  SizedBox(height: 14.h(context)),

                  // Metadata Rows
                  _buildModalDetailRow(
                    context,
                    label: 'رقم المعاملة والوثيقة',
                    value: document.transactionNumber,
                  ),
                  _buildModalDetailRow(
                    context,
                    label: 'الحالة القانونية',
                    value: 'مقبولة ومعتمدة رسمياً',
                    textColor: primaryDarkGreen,
                  ),
                  _buildModalDetailRow(
                    context,
                    label: 'تاريخ الاعتماد',
                    value: document.displayDate,
                  ),

                  if (document.formData != null) ...[
                    SizedBox(height: 8.h(context)),
                    Text(
                      'بيانات الطلب المسجلة:',
                      style: TextStyle(
                        fontSize: 13.f(context),
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryCharcoal,
                      ),
                    ),
                    SizedBox(height: 6.h(context)),
                    ...document.formData!.entries.map((entry) {
                      if (entry.value == null ||
                          entry.value.toString().trim().isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return _buildModalDetailRow(
                        context,
                        label: entry.key,
                        value: entry.value.toString(),
                      );
                    }),
                  ],

                  SizedBox(height: 20.h(context)),

                  // Enlarged QR Code for Inspectors
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(14.s(context)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18.r(context)),
                        border: Border.all(color: Colors.grey.shade300),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: document.qrPayload,
                            version: QrVersions.auto,
                            size: 160.s(context),
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: primaryDarkGreen,
                            ),
                          ),
                          SizedBox(height: 10.h(context)),
                          Text(
                            'امسح الرمز للتحقق',
                            style: TextStyle(
                              fontSize: 12.f(context),
                              fontWeight: FontWeight.bold,
                              color: primaryDarkGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h(context)),

                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryDarkGreen,
                      padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r(context)),
                      ),
                    ),
                    child: Text(
                      'إغلاق التفاصيل',
                      style: TextStyle(
                        fontSize: 14.f(context),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(
    BuildContext context, {
    required String label,
    required String value,
    Color? textColor,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h(context)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.5.f(context),
              color: Colors.grey.shade600,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 12.5.f(context),
                fontWeight: FontWeight.bold,
                color: textColor ?? AppColors.primaryCharcoal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 44.ic(context),
          color: AppColors.alertRed,
        ),
        SizedBox(height: 12.h(context)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5.f(context),
            color: AppColors.primaryCharcoal,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          label: const Text(
            'إعادة المحاولة',
            style: TextStyle(color: Colors.white),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1B5E20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
          ),
        ),
      ],
    );
  }
}
