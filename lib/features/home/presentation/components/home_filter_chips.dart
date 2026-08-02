import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class HomeFilterChips extends StatelessWidget {
  const HomeFilterChips({
    super.key,
    required this.options,
    required this.selectedFilter,
    required this.onFilterSelected,
  });

  final Map<String, String> options;
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          textDirection: TextDirection.rtl,
          children: options.entries.map((entry) {
            final isSelected = selectedFilter == entry.key;
            return Padding(
              padding: EdgeInsetsDirectional.only(end: 8.s(context)),
              child: ChoiceChip(
                label: Text(
                  entry.value,
                  style: TextStyle(
                    fontSize: 13.f(context),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    onFilterSelected(entry.key);
                  }
                },
                selectedColor: primaryColor,
                backgroundColor: Colors.grey[200],
                elevation: isSelected ? 1 : 0,
                padding: EdgeInsets.symmetric(
                  horizontal: 10.s(context),
                  vertical: 6.s(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r(context)),
                  side: BorderSide(
                    color: isSelected ? primaryColor : Colors.transparent,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
