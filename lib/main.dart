import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/myapp.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupServiceLocator();
  await sl.isReady<SharedPreferences>();
  runApp(const MyApp());
}
