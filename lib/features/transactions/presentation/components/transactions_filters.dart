import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsFilters extends StatelessWidget {
  const TransactionsFilters({
    super.key,
    required this.selectedTypeIndex,
    required this.selectedStatusIndex,
  });

  final int selectedTypeIndex;
  final int selectedStatusIndex;

  static const List<({String label, String? typeKey})> typeOptions = [
    (label: 'الكل', typeKey: null),
    (label: 'رخصة تجارية', typeKey: 'commercial_license'),
    (label: 'رخصة بناء', typeKey: 'building_permit'),
    (label: 'خدمة عامة', typeKey: 'general_service'),
  ];

  static const List<({String label, String? statusKey})> statusOptions = [
    (label: 'كل الحالات', statusKey: null),
    (label: 'قيد المراجعة', statusKey: 'pending'),
    (label: 'قيد الدراسة', statusKey: 'under_review'),
    (label: 'بحاجة لوثائق', statusKey: 'needs_documents'),
    (label: 'كشف ميداني', statusKey: 'field_inspection'),
    (label: 'مقبولة', statusKey: 'approved'),
    (label: 'مرفوضة', statusKey: 'rejected'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FilterChipRow(
          options: typeOptions
              .map((e) => (label: e.label, value: e.typeKey))
              .toList(),
          selectedIndex: selectedTypeIndex,
          onSelected: (index, value) {
            context.read<TransactionsCubit>().applyTypeFilter(
                  index: index,
                  type: value,
                );
          },
        ),
        SizedBox(height: 8.h(context)),
        _FilterChipRow(
          options: statusOptions
              .map((e) => (label: e.label, value: e.statusKey))
              .toList(),
          selectedIndex: selectedStatusIndex,
          onSelected: (index, value) {
            context.read<TransactionsCubit>().applyStatusFilter(
                  index: index,
                  status: value,
                );
          },
        ),
      ],
    );
  }
}

class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    required this.options,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<({String label, String? value})> options;
  final int selectedIndex;
  final void Function(int index, String? value) onSelected;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(options.length, (index) {
          final isSelected = selectedIndex == index;
          final filter = options[index];

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
              onSelected: (_) => onSelected(index, filter.value),
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
}
