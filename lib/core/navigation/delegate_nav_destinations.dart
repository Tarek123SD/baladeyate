import 'package:baladeyate/config/theme/app_icons.dart';
import 'package:baladeyate/core/auth/delegate_work_scope.dart';
import 'package:baladeyate/core/navigation/delegate_shell_indices.dart';
import 'package:baladeyate/features/auth/models/user.dart';
import 'package:flutter/material.dart';

class DelegateNavDestination {
  const DelegateNavDestination({
    required this.label,
    required this.icon,
    required this.activeIcon,
    this.branchIndex,
    this.pushPath,
  });

  final String label;
  final IconData icon;
  final IconData activeIcon;
  final int? branchIndex;
  final String? pushPath;

  bool matchesPath(String path) {
    if (pushPath != null) {
      return path == pushPath || path.startsWith('$pushPath/');
    }

    return switch (branchIndex) {
      DelegateShellIndices.home =>
        path == '/delegate/home' ||
            path.startsWith('/delegate/home/') ||
            path == '/delegate/cemetery-map' ||
            path == '/delegate/verify-document',
      DelegateShellIndices.tasks => path == '/delegate/tasks',
      DelegateShellIndices.map => path == '/delegate/map',
      DelegateShellIndices.buildings => path == '/delegate/buildings',
      _ => false,
    };
  }
}

/// Visible bottom-nav items for a delegate, based on assigned work types.
abstract final class DelegateNavDestinations {
  static const home = DelegateNavDestination(
    label: 'الرئيسية',
    icon: AppIcons.navHome,
    activeIcon: AppIcons.navHomeActive,
    branchIndex: DelegateShellIndices.home,
  );

  static const tasks = DelegateNavDestination(
    label: 'المهام',
    icon: AppIcons.navTasks,
    activeIcon: AppIcons.navTasksActive,
    branchIndex: DelegateShellIndices.tasks,
  );

  static const map = DelegateNavDestination(
    label: 'الخريطة',
    icon: AppIcons.navMap,
    activeIcon: AppIcons.navMapActive,
    branchIndex: DelegateShellIndices.map,
  );

  static const buildings = DelegateNavDestination(
    label: 'المباني',
    icon: AppIcons.navBuildings,
    activeIcon: AppIcons.navBuildingsActive,
    branchIndex: DelegateShellIndices.buildings,
  );

  static const complaints = DelegateNavDestination(
    label: 'الشكاوى',
    icon: AppIcons.navComplaints,
    activeIcon: AppIcons.navComplaintsActive,
    pushPath: '/delegate/complaints',
  );

  static const transactions = DelegateNavDestination(
    label: 'المعاملات',
    icon: AppIcons.navTransactions,
    activeIcon: AppIcons.navTransactionsActive,
    pushPath: '/delegate/transactions',
  );

  static List<DelegateNavDestination> forUser(User? user) {
    final destinations = <DelegateNavDestination>[home];

    if (user == null || user.handlesSurveyWork) {
      destinations.addAll([tasks, map, buildings]);
    }

    if (user != null && !user.handlesSurveyWork) {
      if (user.handlesComplaintWork) {
        destinations.add(complaints);
      }
      if (user.handlesTransactionWork) {
        destinations.add(transactions);
      }
    }

    return destinations;
  }
}
