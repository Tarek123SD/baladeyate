import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/config/theme/app_icons.dart';
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
    'المعاملات',
  ];

  static const _icons = [
    AppIcons.navHome,
    AppIcons.navProfile,
    AppIcons.navDonations,
    AppIcons.navComplaints,
    AppIcons.navTransactions,
  ];

  static const _activeIcons = [
    AppIcons.navHomeActive,
    AppIcons.navProfileActive,
    AppIcons.navDonationsActive,
    AppIcons.navComplaintsActive,
    AppIcons.navTransactionsActive,
  ];

  @override
  Widget build(BuildContext context) {
    final radius = 28.r(context);
    final barPaddingV = 8.h(context);
    final iconSize = 24.s(context);
    final labelSize = 11.f(context);
    final pillH = 30.h(context);
    final pillW = 44.w(context);
    final horizontalMargin = 16.w(context);
    final bottomMargin = 14.h(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalMargin,
        0,
        horizontalMargin,
        bottomMargin,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryForest,
              AppColors.secondaryForest,
              AppColors.thirdForest,
            ],
            stops: [0.0, 0.45, 1.0],
          ),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.14),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryForest.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.thirdForest.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 6.w(context),
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
                  gradient: isSelected
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.r(context)),
                  border: isSelected
                      ? Border.all(
                          color: Colors.white.withValues(alpha: 0.4),
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
