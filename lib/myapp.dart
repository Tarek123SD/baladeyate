import 'package:baladeyate/screens/complains_page.dart';
import 'package:baladeyate/screens/main_page.dart';
import 'package:baladeyate/screens/signup.dart';
import 'package:baladeyate/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baladeyate/bloc/auth/auth_bloc.dart';
import 'package:baladeyate/services/auth_service.dart';
// ignore: unused_import
import 'package:baladeyate/screens/login.dart';
import 'package:baladeyate/utils/constants.dart';

/// App widget - root of the application
/// Sets up BlocProvider and MaterialApp
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Create AuthBloc instance and provide it to the widget tree
      create: (context) => AuthBloc(authService: AuthService()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Baladeyate',
        theme: ThemeData(
          // Set primary color
          primaryColor: AppConstants.primaryForest,
          useMaterial3: true,
          // fontFamily: 'Alyamama', // Will be enabled after adding font file
          appBarTheme: const AppBarTheme(
            backgroundColor: AppConstants.thirdCharcoal,
            foregroundColor: Colors.white,
          ),
        ),
        home: const MainPage(),
      ),
    );
  }
}
