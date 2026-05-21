import 'package:baladeyate/core/widgets/custom_app_bar.dart';
import 'package:baladeyate/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Daily tasks screen (map view in [DailyTasksMapScreen] when enabled).
class DailyTasksScreen extends StatelessWidget {
  const DailyTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: Text(AppLocalizations.of(context)!.navTrack),
      ),
    );
  }
}
