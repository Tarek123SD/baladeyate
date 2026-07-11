import 'dart:io';

import 'package:baladeyate/config/constants/storage_keys.dart';
import 'package:baladeyate/core/services/cache_service.dart';
import 'package:baladeyate/features/auth/repo/auth_repository.dart';
import 'package:baladeyate/routes/app_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Registers the device for FCM, shows foreground notifications, and syncs tokens.
class FcmService {
  FcmService({
    required AuthRepository authRepository,
    required CacheService cacheService,
  })  : _authRepository = authRepository,
        _cacheService = cacheService;

  final AuthRepository _authRepository;
  final CacheService _cacheService;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'baladeyate_default';
  static const String channelName = 'إشعارات بلديات';
  static const String channelDescription =
      'تنبيهات المهام والخدمات البلدية';

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    await _initLocalNotifications();
    final permissionGranted = await _requestPermissions();
    if (!permissionGranted) {
      debugPrint('FCM: notification permission not granted');
    }

    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    _messaging.onTokenRefresh.listen((token) {
      debugPrint('FCM token refreshed');
      syncTokenWithBackend();
    });

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    final token = await getToken();
    if (kDebugMode && token != null) {
      debugPrint('FCM token: $token');
    }

    await syncTokenWithBackend();
    _initialized = true;
  }

  Future<String?> getToken() async {
    try {
      if (!kIsWeb && Platform.isIOS) {
        final apnsToken = await _messaging.getAPNSToken();
        if (apnsToken == null) {
          // APNs token can lag slightly after permission grant / cold start.
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
      return await _messaging.getToken();
    } catch (error, stackTrace) {
      debugPrint('FCM getToken failed: $error\n$stackTrace');
      return null;
    }
  }

  Future<void> syncTokenWithBackend() async {
    final sessionToken = _cacheService.getData(key: StorageKeys.token);
    if (sessionToken == null || sessionToken.isEmpty) {
      debugPrint('FCM: skip token sync — user not logged in');
      return;
    }

    final fcmToken = await getToken();
    if (fcmToken == null || fcmToken.isEmpty) {
      debugPrint('FCM: no token available to sync');
      return;
    }

    try {
      await _authRepository.updateFcmToken(fcmToken);
      debugPrint('FCM token synced with backend (${fcmToken.substring(0, 12)}…)');
    } catch (error) {
      debugPrint('FCM token sync failed: $error');
      // One retry — token endpoint can race right after login.
      try {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        await _authRepository.updateFcmToken(fcmToken);
        debugPrint('FCM token synced with backend after retry');
      } catch (retryError) {
        debugPrint('FCM token sync retry failed: $retryError');
      }
    }
  }

  /// Returns true when the user allowed notifications.
  Future<bool> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
      'FCM permission status: ${settings.authorizationStatus.name}',
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted =
        await androidPlugin?.requestNotificationsPermission() ?? true;

    final authorized = settings.authorizationStatus ==
            AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;

    if (!authorized) {
      debugPrint('FCM permission denied by user');
    }
    if (!androidGranted) {
      debugPrint('Android POST_NOTIFICATIONS denied');
    }

    return authorized && androidGranted;
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: (_) => appRouter.go('/notifications'),
    );

    const androidChannel = AndroidNotificationChannel(
      channelId,
      channelName,
      description: channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    debugPrint(
      'FCM foreground message: messageId=${message.messageId}, '
      'notification=${message.notification?.title}, data=${message.data}',
    );

    final notification = message.notification;
    final title = notification?.title ??
        message.data['title']?.toString() ??
        'بلديتي';
    final body = notification?.body ??
        message.data['body']?.toString() ??
        message.data['message']?.toString();

    if (body == null || body.isEmpty) return;

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    await _localNotifications.show(
      notification?.hashCode ?? message.hashCode,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: '/notifications',
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    debugPrint(
      'FCM notification tap: messageId=${message.messageId}, '
      'data=${message.data}',
    );
    appRouter.go('/notifications');
  }
}
