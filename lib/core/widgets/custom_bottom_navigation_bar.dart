import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _labels = [
    'الرئيسية',
    'الملف الشخصي',
    'التبرعات',
    'الشكاوي',
  ];

  static const _icons = [
    Icons.home_outlined,
    Icons.person_outline,
    Icons.volunteer_activism_outlined,
    Icons.support_agent_outlined,
  ];

  static const _activeIcons = [
    Icons.home_rounded,
    Icons.person_rounded,
    Icons.volunteer_activism_rounded,
    Icons.support_agent_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final radius = 18.r(context);
    final barPaddingV = 6.h(context);
    final iconSize = 24.s(context);
    final labelSize = 11.f(context);
    final pillH = 30.h(context);
    final pillW = 44.w(context);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.secondaryForest,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(radius),
          topRight: Radius.circular(radius),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryForest.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 4.w(context),
            vertical: barPaddingV,
          ),
          child: Row(
            children: List.generate(_labels.length, (index) {
              final isSelected = index == currentIndex;
              return Expanded(
                child: _NavItem(
                  label: _labels[index],
                  icon: isSelected ? _activeIcons[index] : _icons[index],
                  isSelected: isSelected,
                  onTap: () => onTap(index),
                  iconSize: iconSize,
                  labelSize: labelSize,
                  pillH: pillH,
                  pillW: pillW,
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;
  final double pillH;
  final double pillW;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.iconSize,
    required this.labelSize,
    required this.pillH,
    required this.pillW,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r(context)),
        splashColor: Colors.white.withValues(alpha: 0.12),
        highlightColor: Colors.white.withValues(alpha: 0.08),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2.h(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                height: pillH,
                width: pillW,
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.white.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r(context)),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.35),
                        )
                      : null,
                ),
                child: Icon(
                  icon,
                  size: iconSize,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                ),
              ),
              SizedBox(height: 2.h(context)),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontSize: labelSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.65),
                  height: 1.1,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
