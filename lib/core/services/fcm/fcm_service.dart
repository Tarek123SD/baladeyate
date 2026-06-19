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
    await _requestPermissions();

    _messaging.onTokenRefresh.listen((_) => syncTokenWithBackend());

    FirebaseMessaging.onMessage.listen(_showForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    await syncTokenWithBackend();
    _initialized = true;
  }

  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (error, stackTrace) {
      debugPrint('FCM getToken failed: $error\n$stackTrace');
      return null;
    }
  }

  Future<void> syncTokenWithBackend() async {
    final sessionToken = _cacheService.getData(key: StorageKeys.token);
    if (sessionToken == null || sessionToken.isEmpty) return;

    final fcmToken = await getToken();
    if (fcmToken == null || fcmToken.isEmpty) return;

    try {
      await _authRepository.updateFcmToken(fcmToken);
    } catch (error) {
      debugPrint('FCM token sync failed: $error');
    }
  }

  Future<void> _requestPermissions() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('FCM permission denied');
    }

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> _initLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

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
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
  }

  Future<void> _showForegroundNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: '/notifications',
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    appRouter.go('/notifications');
  }
}
