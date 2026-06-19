import 'package:baladeyate/core/services/fcm/firebase_messaging_background.dart';
import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/firebase_options.dart';
import 'package:baladeyate/myapp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setupServiceLocator();
  await sl.isReady<SharedPreferences>();
  await sl<FcmService>().initialize();
  runApp(const MyApp());
}
