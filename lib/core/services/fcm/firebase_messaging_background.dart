import 'package:baladeyate/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Handles FCM data messages when the app is in the background or terminated.
/// Notification-payload messages are shown by the OS automatically.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  debugPrint(
    'FCM background message: messageId=${message.messageId}, '
    'notification=${message.notification?.title}, data=${message.data}',
  );
}
