import 'package:baladeyate/features/transactions/cubits/transactions_cubit/transactions_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TransactionsFilters extends StatelessWidget {
  const TransactionsFilters({
    super.key,
    required this.selectedIndex,
  });

  final int selectedIndex;

  static const List<({String label, String? typeKey})> filterOptions = [
    (label: 'الكل', typeKey: null),
    (label: 'رخصة تجارية', typeKey: 'commercial_license'),
    (label: 'رخصة بناء', typeKey: 'building_permit'),
  ];

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(filterOptions.length, (index) {
          final isSelected = selectedIndex == index;
          final filter = filterOptions[index];

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
}
