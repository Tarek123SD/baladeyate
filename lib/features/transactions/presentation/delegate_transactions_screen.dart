import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/core/widgets/responsive_body.dart';
import 'package:baladeyate/features/transactions/cubits/delegate_transactions_cubit/delegate_transactions_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/delegate_transactions_cubit/delegate_transactions_state.dart';
import 'package:baladeyate/features/transactions/models/transaction_model.dart';
import 'package:baladeyate/features/transactions/presentation/transaction_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateTransactionsScreen extends StatelessWidget {
  const DelegateTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DelegateTransactionsCubit>()..fetch(),
      child: const _DelegateTransactionsView(),
    );
  }
}

class _DelegateTransactionsView extends StatelessWidget {
  const _DelegateTransactionsView();

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

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
            child: BlocConsumer<DelegateTransactionsCubit,
                DelegateTransactionsState>(
              listener: (context, state) {
                if (state is DelegateTransactionsError) {
                  AppSnackBar.showError(context, state.message);
                }
              },
              builder: (context, state) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () =>
                      context.read<DelegateTransactionsCubit>().fetch(),
                  child: ResponsiveBody(
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: 8.h(context),
                              bottom: 16.h(context),
                            ),
                            child: Text(
                              'معاملات المعاينة الميدانية',
                              style: TextStyle(
                                fontSize: 18.f(context),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        if (state is DelegateTransactionsLoading)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.pageProgress(context),
                              ),
                            ),
                          )
                        else if (state is DelegateTransactionsLoaded &&
                            state.transactions.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Text(
                                'لا توجد معاملات بانتظار المعاينة حالياً',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14.f(context),
                                ),
                              ),
                            ),
                          )
                        else if (state is DelegateTransactionsLoaded)
                          SliverList.builder(
                            itemCount: state.transactions.length,
                            itemBuilder: (context, index) {
                              final tx = state.transactions[index];
                              return _DelegateTransactionTile(
                                transaction: tx,
                                onInspect: () =>
                                    _showInspectSheet(context, tx),
                              );
                            },
                          )
                        else
                          const SliverToBoxAdapter(child: SizedBox.shrink()),
                        SliverToBoxAdapter(
                          child: SizedBox(height: 24.h(context)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showInspectSheet(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final notesController = TextEditingController();
    final cubit = context.read<DelegateTransactionsCubit>();

    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24.r(sheetContext)),
                ),
              ),
              padding: EdgeInsets.all(20.s(sheetContext)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'تقرير المعاينة — ${transaction.transactionNumber}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.f(sheetContext),
                    ),
                  ),
                  SizedBox(height: 12.h(sheetContext)),
                  TextField(
                    controller: notesController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'اكتب ملاحظات المعاينة الميدانية...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 16.h(sheetContext)),
                  ElevatedButton(
                    onPressed: () {
                      if (notesController.text.trim().isEmpty) return;
                      Navigator.pop(sheetContext, true);
                    },
                    child: const Text('إرسال التقرير'),
                  ),
                  SizedBox(height: 8.h(sheetContext)),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (submitted == true && context.mounted) {
      final ok = await cubit.submitInspection(
        transactionId: transaction.id,
        notes: notesController.text.trim(),
      );
      if (!context.mounted) return;
      if (ok) {
        AppSnackBar.showSuccess(context, 'تم إرسال تقرير المعاينة');
      }
    }

    notesController.dispose();
  }
}

class _DelegateTransactionTile extends StatelessWidget {
  const _DelegateTransactionTile({
    required this.transaction,
    required this.onInspect,
  });

  final TransactionModel transaction;
  final VoidCallback onInspect;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h(context)),
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
            getTransactionTypeLabel(transaction.type),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15.f(context),
            ),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            transaction.transactionNumber,
            style: TextStyle(
              color: primaryColor,
              fontWeight: FontWeight.w600,
              fontSize: 13.f(context),
            ),
          ),
          SizedBox(height: 12.h(context)),
          ElevatedButton.icon(
            onPressed: onInspect,
            icon: const Icon(Icons.fact_check_outlined, color: Colors.white),
            label: const Text(
              'تقديم تقرير معاينة',
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
    );
  }
}
