import 'package:baladeyate/router/app_router.dart';
import 'package:baladeyate/screens/complains_page.dart';
import 'package:baladeyate/screens/donations.dart';
import 'package:baladeyate/screens/family_profile.dart';
import 'package:baladeyate/screens/main_page.dart';
import 'package:baladeyate/screens/notifications.dart';
import 'package:baladeyate/screens/settings.dart';
import 'package:baladeyate/screens/signup.dart';
import 'package:baladeyate/screens/splash_screen.dart';
import 'package:baladeyate/screens/track_complains.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/bloc/auth/auth_bloc.dart';
import 'package:baladeyate/services/auth_service.dart';
// ignore: unused_import
import 'package:baladeyate/screens/login.dart';
import 'package:baladeyate/utils/constants.dart';
import 'package:go_router/go_router.dart';

/// App widget - root of the application
/// Sets up BlocProvider and MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create AuthBloc instance and provide it to the widget tree
      create: (context) => AuthBloc(authService: AuthService()),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Baladeyate',
        theme: ThemeData(
          fontFamily: 'Alyamama',
          // Set primary color
          primaryColor: AppConstants.primaryForest,
          useMaterial3: true,
          // fontFamily: 'Alyamama', // Will be enabled after adding font file
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.thirdCharcoal,
            foregroundColor: Colors.white,
          ),
        ),
        routerConfig: appRouter,
      ),
    );
  }
}
