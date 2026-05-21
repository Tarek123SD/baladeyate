import 'package:baladeyate/config/theme/app_theme.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/l10n/app_localizations.dart';

/// Root app widget: theme, localization, auth cubit, and routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: appRouter,
      ),
    );
  }
}
