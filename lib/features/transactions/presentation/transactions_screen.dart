import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/constants/app_assets.dart';
import 'package:baladeyate/core/responsive/responsive_helper.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/core/utils/app_snackbar.dart';
import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_cubit.dart';
import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_state.dart';
import 'package:baladeyate/features/transactions/presentation/components/transaction_card.dart';
import 'package:baladeyate/features/transactions/presentation/components/transactions_empty_state.dart';
import 'package:baladeyate/features/transactions/presentation/components/transactions_error_section.dart';
import 'package:baladeyate/features/transactions/presentation/components/transactions_filters.dart';
import 'package:baladeyate/features/transactions/presentation/components/transactions_header_card.dart';
import 'package:baladeyate/features/transactions/presentation/components/transactions_list_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionsCubit>().fetchTransactions();
    });
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveHelper.horizontalPadding(context);
    final primaryColor = Theme.of(context).colorScheme.primary;

    return BlocListener<TransactionsCubit, TransactionsState>(
      listener: (context, state) {
        if (state is TransactionsError) {
          AppSnackBar.showError(context, state.message);
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
            onPressed: () async {
              final result = await context.push<bool>('/transactions/submit');
              if (result == true && context.mounted) {
                context.read<TransactionsCubit>().fetchTransactions();
              }
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
                                const TransactionsHeaderCard()
                                    .animate()
                                    .fadeIn(duration: 300.ms)
                                    .slideY(begin: -0.05, end: 0),
                                SizedBox(height: 16.h(context)),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: BlocBuilder<TransactionsCubit,
                                TransactionsState>(
                              builder: (context, state) {
                                final typeIndex = state is TransactionsLoaded
                                    ? state.selectedTypeFilterIndex
                                    : 0;
                                final statusIndex = state is TransactionsLoaded
                                    ? state.selectedStatusFilterIndex
                                    : 0;

                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    TransactionsFilters(
                                      selectedTypeIndex: typeIndex,
                                      selectedStatusIndex: statusIndex,
                                      typeOptions: state is TransactionsLoaded &&
                                              state.typeOptions.isNotEmpty
                                          ? state.typeOptions
                                          : TransactionsFilters.defaultTypeOptions,
                                    ),
                                    SizedBox(height: 16.h(context)),
                                    TransactionsListHeader(
                                      count: state is TransactionsLoaded
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
                                      color: AppColors.pageProgress(context),
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
                                  child: TransactionsErrorSection(
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
                                  sliver: const SliverToBoxAdapter(
                                    child: TransactionsEmptyState(),
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
                                    return TransactionCard(
                                      transaction: transaction,
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
}
