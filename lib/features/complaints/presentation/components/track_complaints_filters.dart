import 'package:baladeyate/features/complaints/cubits/complaints_cubit/complaints_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class TrackComplaintsFilters extends StatelessWidget {
  const TrackComplaintsFilters({
    super.key,
    required this.selectedFilter,
  });

  final int selectedFilter;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final filters = [
      (index: 0, label: 'الكل'),
      (index: 1, label: 'قيد الانتظار'),
      (index: 2, label: 'مكتملة'),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter.index;
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
                context.read<ComplaintsCubit>().setFilter(filter.index);
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
        }).toList(),
      ),
    );
  }
}
