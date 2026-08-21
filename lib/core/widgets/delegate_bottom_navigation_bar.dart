import 'package:baladeyate/config/theme/app_colors.dart';
import 'package:baladeyate/core/navigation/delegate_nav_destinations.dart';
import 'package:flutter/material.dart';
import 'package:responsive_x_toolkit/responsive_x.dart';

class DelegateBottomNavigationBar extends StatelessWidget {
  const DelegateBottomNavigationBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<DelegateNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Vertical space occupied by the floating nav (bar + outer bottom margin).
  static double clearance(BuildContext context) {
    final bottomMargin = 14.h(context);
    final barPaddingV = 8.h(context);
    final pillH = 30.h(context);
    final labelSize = 11.f(context);
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    return bottomMargin +
        safeBottom +
        (barPaddingV * 2) +
        pillH +
        2.h(context) +
        (labelSize * 1.15);
  }

  @override
  Widget build(BuildContext context) {
    final items = destinations.isEmpty
        ? const [DelegateNavDestinations.home]
        : destinations;
    final radius = 28.r(context);
    final barPaddingV = 8.h(context);
    final iconSize = 24.s(context);
    final labelSize = 11.f(context);
    final pillH = 30.h(context);
    final pillW = 44.w(context);
    final horizontalMargin = 16.w(context);
    final bottomMargin = 14.h(context);
    final safeSelected = selectedIndex.clamp(0, items.length - 1);

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
                children: List.generate(items.length, (index) {
                  final item = items[index];
                  final isSelected = index == safeSelected;
                  return Expanded(
                    child: _NavItem(
                      label: item.label,
                      icon: isSelected ? item.activeIcon : item.icon,
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

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final double iconSize;
  final double labelSize;
  final double pillH;
  final double pillW;

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
