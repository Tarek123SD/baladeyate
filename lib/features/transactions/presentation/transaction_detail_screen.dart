import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/transactions/cubits/transaction_detail_cubit/transaction_detail_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/transaction_detail_cubit/transaction_detail_state.dart';
import 'package:baladeyate/features/transactions/presentation/components/file_attachments_list.dart';
import 'package:baladeyate/features/transactions/presentation/components/file_picker_container.dart';
import 'package:baladeyate/features/transactions/presentation/components/required_documents_guide.dart';
import 'package:baladeyate/features/transactions/presentation/transaction_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionDetailScreen extends StatelessWidget {
  const TransactionDetailScreen({super.key, required this.transactionId});

  final int transactionId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TransactionDetailCubit(
        repository: sl(),
        transactionId: transactionId,
      )..load(),
      child: const _TransactionDetailView(),
    );
  }
}

class _TransactionDetailView extends StatelessWidget {
  const _TransactionDetailView();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppAssets.backgroundWhite),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: const CustomAppBar(showBackButton: true),
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: BlocConsumer<TransactionDetailCubit, TransactionDetailState>(
              listener: (context, state) {
                if (state is TransactionDetailError) {
                  AppSnackBar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                if (state is TransactionDetailLoading ||
                    state is TransactionDetailInitial) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.pageProgress(context),
                    ),
                  );
                }

                if (state is TransactionDetailError) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.s(context)),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message, textAlign: TextAlign.center),
                          SizedBox(height: 16.h(context)),
                          ElevatedButton(
                            onPressed: () =>
                                context.read<TransactionDetailCubit>().load(),
                            child: const Text('إعادة المحاولة'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is! TransactionDetailLoaded) {
                  return const SizedBox.shrink();
                }

                return _LoadedBody(state: state);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadedBody extends StatelessWidget {
  const _LoadedBody({required this.state});

  final TransactionDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    final transaction = state.transaction;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusProps = getTransactionStatusProps(transaction.status);
    final cubit = context.read<TransactionDetailCubit>();
    final busy = state.isUploading || state.isCancelling;

    return RefreshIndicator(
      color: primaryColor,
      onRefresh: cubit.load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ResponsiveBody(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 8.h(context)),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      getTransactionTypeLabel(transaction.type),
                      style: TextStyle(
                        fontSize: 18.f(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w(context),
                      vertical: 4.h(context),
                    ),
                    decoration: BoxDecoration(
                      color: statusProps.bgColor,
                      borderRadius: BorderRadius.circular(16.r(context)),
                    ),
                    child: Text(
                      statusProps.label,
                      style: TextStyle(
                        color: statusProps.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.f(context),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h(context)),
              Text(
                'رقم المعاملة: ${transaction.transactionNumber}',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.f(context),
                ),
              ),
              SizedBox(height: 4.h(context)),
              Text(
                'تاريخ التقديم: ${formatTransactionDate(transaction.createdAt)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12.f(context),
                ),
              ),
              if (transaction.adminNotes != null &&
                  transaction.adminNotes!.trim().isNotEmpty) ...[
                SizedBox(height: 16.h(context)),
                const _SectionTitle(title: 'ملاحظات البلدية'),
                SizedBox(height: 8.h(context)),
                Text(
                  transaction.adminNotes!,
                  style: TextStyle(
                    fontSize: 13.f(context),
                    color: Colors.grey.shade800,
                    height: 1.4,
                  ),
                ),
              ],
              if (transaction.formData != null &&
                  transaction.formData!.isNotEmpty) ...[
                SizedBox(height: 16.h(context)),
                const _SectionTitle(title: 'بيانات الطلب'),
                SizedBox(height: 8.h(context)),
                ...transaction.formData!.entries.map((entry) {
                  final label =
                      transactionFormDataLabels[entry.key] ?? entry.key;
                  final value = formatTransactionFormDataValue(
                    entry.key,
                    entry.value,
                  );
                  return Padding(
                    padding: EdgeInsets.only(bottom: 6.h(context)),
                    child: Text('• $label: $value'),
                  );
                }),
              ],
              if (transaction.attachments.isNotEmpty) ...[
                SizedBox(height: 16.h(context)),
                const _SectionTitle(title: 'المرفقات'),
                SizedBox(height: 8.h(context)),
                ...transaction.attachments.map((url) {
                  final name = url.split('/').last;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(Icons.attach_file, color: primaryColor),
                    title: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13.f(context)),
                    ),
                    trailing: IconButton(
                      tooltip: 'نسخ الرابط',
                      icon: const Icon(Icons.copy_outlined, size: 18),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: url));
                        if (context.mounted) {
                          AppSnackBar.showSuccess(context, 'تم نسخ رابط المرفق');
                        }
                      },
                    ),
                  );
                }),
              ],
              if (transaction.statusHistory.isNotEmpty) ...[
                SizedBox(height: 16.h(context)),
                const _SectionTitle(title: 'سجل الحالات'),
                SizedBox(height: 8.h(context)),
                ...transaction.statusHistory.map((item) {
                  final label = getTransactionStatusProps(item.toStatus).label;
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8.h(context)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.timeline,
                          size: 16.ic(context),
                          color: primaryColor,
                        ),
                        SizedBox(width: 8.w(context)),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                label,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13.f(context),
                                ),
                              ),
                              if (item.createdAt != null)
                                Text(
                                  formatTransactionDate(item.createdAt!),
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 11.f(context),
                                  ),
                                ),
                              if (item.note != null &&
                                  item.note!.trim().isNotEmpty)
                                Text(
                                  item.note!,
                                  style: TextStyle(
                                    color: Colors.grey.shade700,
                                    fontSize: 12.f(context),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              if (transaction.needsDocuments) ...[
                SizedBox(height: 24.h(context)),
                const _SectionTitle(title: 'رفع وثائق إضافية'),
                SizedBox(height: 8.h(context)),
                RequiredDocumentsGuide(
                  type: transaction.type,
                  compact: true,
                ),
                SizedBox(height: 12.h(context)),
                FilePickerContainer(
                  label: 'انقر لإرفاق الوثائق المطلوبة',
                  onTap: busy ? () {} : cubit.pickFiles,
                ),
                if (state.pendingFiles.isNotEmpty) ...[
                  SizedBox(height: 8.h(context)),
                  FileAttachmentsList(
                    files: state.pendingFiles,
                    onRemove: busy ? (_) {} : cubit.removePendingFile,
                  ),
                ],
                SizedBox(height: 12.h(context)),
                ElevatedButton(
                  onPressed: busy || state.pendingFiles.isEmpty
                      ? null
                      : () async {
                          final message = await cubit.uploadDocuments();
                          if (!context.mounted) return;
                          if (message == null) {
                            AppSnackBar.showSuccess(
                              context,
                              'تم رفع الوثائق بنجاح',
                            );
                          } else {
                            AppSnackBar.showError(context, message);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor:
                        primaryColor.withValues(alpha: 0.7),
                    disabledForegroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                  ),
                  child: state.isUploading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.contrastingProgress(primaryColor),
                          ),
                        )
                      : const Text(
                          'إرسال الوثائق',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
              if (transaction.canCancel) ...[
                SizedBox(height: 16.h(context)),
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('إلغاء المعاملة'),
                              content: const Text(
                                'هل أنت متأكد من إلغاء هذه المعاملة؟',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('تراجع'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  child: const Text('تأكيد الإلغاء'),
                                ),
                              ],
                            ),
                          );
                          if (confirmed != true || !context.mounted) return;
                          final message = await cubit.cancel();
                          if (!context.mounted) return;
                          if (message == null) {
                            AppSnackBar.showSuccess(
                              context,
                              'تم إلغاء المعاملة',
                            );
                          } else {
                            AppSnackBar.showError(context, message);
                          }
                        },
                  child: state.isCancelling
                      ? SizedBox(
                          height: 18.h(context),
                          width: 18.w(context),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red.shade700,
                          ),
                        )
                      : Text(
                          'إلغاء المعاملة',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ],
              SizedBox(height: 32.h(context)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.f(context),
      ),
    );
  }
}
