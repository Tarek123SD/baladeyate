import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';

import '../cubits/transactions_cubit/transactions_cubit.dart';
import '../cubits/transactions_cubit/transactions_state.dart';
import '../models/transaction_model.dart';

/// Transactions & Licenses hub connected to Laravel API GET /api/v1/transactions
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      BlocProvider.of<TransactionsCubit>(context);
      return const TransactionsView();
    } catch (_) {
      return BlocProvider(
        create: (context) => sl<TransactionsCubit>()..fetchTransactions(),
        child: const TransactionsView(),
      );
    }
  }
}

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  static const List<({String label, String? typeKey})> _filterOptions = [
    (label: 'الكل', typeKey: null),
    (label: 'رخصة تجارية', typeKey: 'commercial_license'),
    (label: 'رخصة بناء', typeKey: 'building_permit'),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsCubit>().fetchTransactions();
    });
  }

  /// 4. Dynamic Data Mapping: _getStatusProps(String status)
  ({String label, Color color, Color bgColor, IconData icon}) _getStatusProps(
    String status,
  ) {
    switch (status.toLowerCase()) {
      case 'field_inspection':
      case 'kashf':
        return (
          label: 'كشف ميداني',
          color: const Color(0xFF4527A0), // Purple/Indigo
          bgColor: const Color(0xFFEDE7F6),
          icon: Icons.fact_check_outlined,
        );
      case 'under_review':
      case 'processing':
      case 'in_progress':
        return (
          label: 'قيد الدراسة',
          color: const Color(0xFF1565C0), // Blue
          bgColor: const Color(0xFFE3F2FD),
          icon: Icons.sync_rounded,
        );
      case 'approved':
      case 'completed':
        return (
          label: 'مقبولة',
          color: const Color(0xFF2E7D32), // Green
          bgColor: const Color(0xFFE8F5E9),
          icon: Icons.check_circle_rounded,
        );
      case 'rejected':
        return (
          label: 'مرفوضة',
          color: const Color(0xFFC62828), // Red
          bgColor: const Color(0xFFFFEBEE),
          icon: Icons.cancel_rounded,
        );
      case 'pending':
      default:
        return (
          label: 'قيد المراجعة',
          color: const Color(0xFFE65100), // Orange
          bgColor: const Color(0xFFFFF3E0),
          icon: Icons.hourglass_top_rounded,
        );
    }
  }

  /// 4. Dynamic Data Mapping: _getTypeLabel(String type)
  String _getTypeLabel(String type) {
    switch (type.toLowerCase()) {
      case 'commercial_license':
        return 'رخصة تجارية';
      case 'building_permit':
        return 'رخصة بناء';
      default:
        if (type.trim().isNotEmpty) {
          return type;
        }
        return 'معاملة بلدية';
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return 'تاريخ غير متوفر';
    final parsed = DateTime.tryParse(dateStr);
    if (parsed == null) return dateStr;
    return '${parsed.day}/${parsed.month}/${parsed.year}';
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<TransactionsCubit, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.alertRed,
            ),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage(AppAssets.backgroundWhite),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.grey.shade50,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          appBar: const CustomAppBar(),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'new_transaction_fab',
            onPressed: () {
              context.push('/transactions/submit');
            },
            backgroundColor: primaryColor,
            elevation: 3,
            icon: const Icon(Icons.assignment_add, color: Colors.white),
            label: Text(
              'معاملة جديدة',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13.f(context),
              ),
            ),
          ),
          body: SafeArea(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 900.w(context)),
                  child: RefreshIndicator(
                    color: primaryColor,
                    onRefresh: () =>
                        context.read<TransactionsCubit>().fetchTransactions(),
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      slivers: [
                        // 1. Top Header
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            horizontalPadding,
                            16.h(context),
                            horizontalPadding,
                            0,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildHeaderCard(context)
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideY(begin: -0.05, end: 0),
                                SizedBox(height: 16.h(context)),
                              ],
                            ),
                          ),
                        ),

                        // 2. Filter Chips
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: BlocBuilder<TransactionsCubit, TransactionsState>(
                              builder: (context, state) {
                                final selectedIndex = state is TransactionsLoaded
                                    ? state.selectedFilterIndex
                                    : 0;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _buildFilterChips(context, selectedIndex),
                                    SizedBox(height: 16.h(context)),
                                    _buildListHeader(
                                      context,
                                      state is TransactionsLoaded
                                          ? state.transactions.length
                                          : 0,
                                    ),
                                    SizedBox(height: 12.h(context)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ),

                        // 3. Transactions List state builder
                        BlocBuilder<TransactionsCubit, TransactionsState>(
                          builder: (context, state) {
                            if (state is TransactionsLoading) {
                              return SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 40.h(context),
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                              );
                            }

                            if (state is TransactionsError) {
                              return SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                  vertical: 30.h(context),
                                ),
                                sliver: SliverToBoxAdapter(
                                  child: _buildErrorState(
                                    context,
                                    message: state.message,
                                    onRetry: () => context
                                        .read<TransactionsCubit>()
                                        .fetchTransactions(),
                                  ),
                                ),
                              );
                            }

                            if (state is TransactionsLoaded) {
                              final transactions = state.transactions;

                              if (transactions.isEmpty) {
                                return SliverPadding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: horizontalPadding,
                                  ),
                                  sliver: SliverToBoxAdapter(
                                    child: _buildEmptyState(context),
                                  ),
                                );
                              }

                              return SliverPadding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: horizontalPadding,
                                ),
                                sliver: SliverList.builder(
                                  itemCount: transactions.length,
                                  itemBuilder: (context, index) {
                                    final transaction = transactions[index];
                                    return _buildTransactionCard(
                                      context,
                                      transaction,
                                    )
                                        .animate()
                                        .fadeIn(
                                          duration: 250.ms,
                                          delay: (30 * index).ms,
                                        )
                                        .slideY(begin: 0.04, end: 0);
                                  },
                                ),
                              );
                            }

                            return const SliverToBoxAdapter(
                              child: SizedBox.shrink(),
                            );
                          },
                        ),

                        // Bottom clearance for FAB
                        SliverToBoxAdapter(
                          child: SizedBox(height: 80.h(context)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Top Header Container
  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: AppColors.primaryForest,
        borderRadius: BorderRadius.circular(16.r(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.s(context)),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12.r(context)),
            ),
            child: Icon(
              Icons.assignment_turned_in_rounded,
              color: Colors.white,
              size: 26.ic(context),
            ),
          ),
          SizedBox(width: 12.w(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مركز المعاملات والرخص',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.f(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h(context)),
                Text(
                  'متابعة وإدارة معاملاتك البلدية ورخص المنشآت بدقة وسهولة',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12.f(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 5. Filter Chips Logic
  Widget _buildFilterChips(BuildContext context, int selectedIndex) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(_filterOptions.length, (index) {
          final isSelected = selectedIndex == index;
          final filter = _filterOptions[index];

          return Padding(
            padding: EdgeInsets.only(left: 8.w(context)),
            child: ChoiceChip(
              label: Text(
                filter.label,
                style: TextStyle(
                  fontSize: 12.f(context),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.grey.shade800,
                ),
              ),
              selected: isSelected,
              showCheckmark: false,
              onSelected: (_) {
                context.read<TransactionsCubit>().fetchTransactions(
                      type: filter.typeKey,
                      filterIndex: index,
                    );
              },
              selectedColor: primaryColor,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected ? primaryColor : Colors.grey.shade300,
                width: 1,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r(context)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: 12.w(context),
                vertical: 6.h(context),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildListHeader(BuildContext context, int count) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        Container(
          width: 4.w(context),
          height: 16.h(context),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(2.r(context)),
          ),
        ),
        SizedBox(width: 8.w(context)),
        Text(
          'قائمة المعاملات المتاحة',
          style: TextStyle(
            fontSize: 14.f(context),
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const Spacer(),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 10.w(context),
            vertical: 4.h(context),
          ),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r(context)),
          ),
          child: Text(
            '$count معاملة',
            style: TextStyle(
              fontSize: 12.f(context),
              fontWeight: FontWeight.bold,
              color: primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  /// Dynamic Transaction Card
  Widget _buildTransactionCard(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusProps = _getStatusProps(transaction.status);
    final typeLabel = _getTypeLabel(transaction.type);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h(context)),
      padding: EdgeInsets.all(16.s(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r(context)),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ROW 1: Right -> Transaction Type; Left -> Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  typeLabel,
                  style: TextStyle(
                    fontSize: 15.f(context),
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              SizedBox(width: 8.w(context)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w(context),
                  vertical: 4.h(context),
                ),
                decoration: BoxDecoration(
                  color: statusProps.bgColor,
                  borderRadius: BorderRadius.circular(20.r(context)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      statusProps.icon,
                      size: 13.ic(context),
                      color: statusProps.color,
                    ),
                    SizedBox(width: 4.w(context)),
                    Text(
                      statusProps.label,
                      style: TextStyle(
                        fontSize: 11.f(context),
                        fontWeight: FontWeight.bold,
                        color: statusProps.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h(context)),

          // ROW 2: Transaction Number • Date
          Row(
            children: [
              Text(
                transaction.transactionNumber,
                style: TextStyle(
                  fontSize: 13.f(context),
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 6.w(context)),
                child: Text(
                  '•',
                  style: TextStyle(
                    fontSize: 12.f(context),
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_outlined,
                size: 12.ic(context),
                color: Colors.grey.shade600,
              ),
              SizedBox(width: 4.w(context)),
              Text(
                _formatDate(transaction.createdAt),
                style: TextStyle(
                  fontSize: 12.f(context),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // DIVIDER
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12.h(context)),
            child: Divider(
              color: Colors.grey.shade200,
              height: 1,
              thickness: 1,
            ),
          ),

          // ROW 3 (Footer): Details Action Link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (transaction.formData != null &&
                  transaction.formData!.isNotEmpty)
                Expanded(
                  child: Text(
                    transaction.formData!.entries
                        .take(2)
                        .map((e) => '${e.key}: ${e.value}')
                        .join(' • '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.f(context),
                      color: Colors.grey.shade600,
                    ),
                  ),
                )
              else
                const Spacer(),
              SizedBox(width: 8.w(context)),
              InkWell(
                onTap: () => _showTransactionDetailsBottomSheet(
                  context,
                  transaction,
                ),
                borderRadius: BorderRadius.circular(8.r(context)),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 6.w(context),
                    vertical: 4.h(context),
                  ),
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
                      SizedBox(width: 4.w(context)),
                      Icon(
                        Icons.chevron_left_rounded,
                        color: primaryColor,
                        size: 18.ic(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTransactionDetailsBottomSheet(
    BuildContext context,
    TransactionModel transaction,
  ) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final statusProps = _getStatusProps(transaction.status);
    final typeLabel = _getTypeLabel(transaction.type);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24.r(context)),
              ),
            ),
            padding: EdgeInsets.all(20.s(context)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      typeLabel,
                      style: TextStyle(
                        fontSize: 17.f(context),
                        fontWeight: FontWeight.bold,
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
                  'تاريخ التقديم: ${_formatDate(transaction.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.f(context),
                  ),
                ),
                SizedBox(height: 16.h(context)),
                if (transaction.formData != null &&
                    transaction.formData!.isNotEmpty) ...[
                  const Divider(),
                  SizedBox(height: 8.h(context)),
                  Text(
                    'البيانات المرفقة بالطلب:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.f(context),
                    ),
                  ),
                  SizedBox(height: 8.h(context)),
                  ...transaction.formData!.entries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 6.h(context)),
                      child: Row(
                        children: [
                          Text(
                            '• ${entry.key}: ',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.f(context),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              '${entry.value}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13.f(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  SizedBox(height: 16.h(context)),
                ],
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 12.h(context)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r(context)),
                      ),
                    ),
                    child: Text(
                      'إغلاق',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.f(context),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h(context)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h(context)),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_late_outlined,
            size: 56.ic(context),
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 12.h(context)),
          Text(
            'لا توجد معاملات حالياً',
            style: TextStyle(
              fontSize: 15.f(context),
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 4.h(context)),
          Text(
            'يمكنك تقديم معاملة جديدة من خلال الزر في الأسفل',
            style: TextStyle(
              fontSize: 12.f(context),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context, {
    required String message,
    required VoidCallback onRetry,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 48.ic(context),
          color: AppColors.alertRed,
        ),
        SizedBox(height: 12.h(context)),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.f(context),
            color: Colors.grey.shade800,
          ),
        ),
        SizedBox(height: 16.h(context)),
        ElevatedButton.icon(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          label: const Text('إعادة المحاولة'),
        ),
      ],
    );
  }
}
