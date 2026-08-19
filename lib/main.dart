import 'dart:io' show Platform;

import 'package:baladeyate/core/services/fcm/firebase_messaging_background.dart';
import 'package:baladeyate/core/services/fcm/fcm_service.dart';
import 'package:baladeyate/core/services/service_locator.dart';
import 'package:baladeyate/firebase_options.dart';
import 'package:baladeyate/myapp.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter_android/google_maps_flutter_android.dart';
import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureGoogleMaps();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  await setupServiceLocator();
  await sl.isReady<SharedPreferences>();
  await sl<FcmService>().initialize();
  runApp(const MyApp());
}

Future<void> _configureGoogleMaps() async {
  if (kIsWeb || !Platform.isAndroid) return;
  final mapsImplementation = GoogleMapsFlutterPlatform.instance;
  if (mapsImplementation is! GoogleMapsFlutterAndroid) return;
  try {
    await mapsImplementation.initializeWithRenderer(AndroidMapRenderer.latest);
  } catch (_) {
    // Fall back to the platform default renderer if initialization fails.
  }
}
