import 'package:baladeyate/config/theme/app_theme.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_cubit.dart';
import 'package:baladeyate/features/auth/cubits/auth_cubit/auth_state.dart';
import 'package:baladeyate/features/notifications/cubits/notifications_cubit/notifications_cubit.dart';
import 'package:baladeyate/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/l10n/app_localizations.dart';

/// Root app widget: theme, localization, auth cubit, and routing.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: sl<AuthCubit>()),
        BlocProvider.value(value: sl<NotificationsCubit>()),
      ],
      child: BlocListener<AuthCubit, AuthState>(
        listenWhen: (previous, current) =>
            previous.runtimeType != current.runtimeType,
        listener: (context, state) {
          final notificationsCubit = context.read<NotificationsCubit>();
          if (state is AuthSuccess) {
            notificationsCubit.loadNotifications();
          } else if (state is AuthLoggedOut || state is AuthFailure) {
            notificationsCubit.clear();
          }
        },
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          locale: const Locale('en', 'US'),
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: appRouter,
          builder: (context, child) {
            return Directionality(
              textDirection: TextDirection.ltr,
              child: child!,
            );
          },
        ),
      ),
    );
  }
}
