import 'dart:ffi';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final msbService = FirebaseMessaging.instance;
  final String topic = 'home_management';
  bool isNotificationsEnabled = true;

  Future<String?> initFCM() async {
    try {
      // İzin iste
      NotificationSettings settings = await msbService.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Notification permission granted');

        // iOS için APNS token kontrolü
        if (Platform.isIOS) {
          return await _getiOSFCMToken();
        } else {
          // Android için direkt FCM token al
          return await _getAndroidFCMToken();
        }
      } else {
        print('Notification permission denied');
        return null;
      }
    } catch (e) {
      print('Error initializing FCM: $e');
      return null;
    }
  }

  Future<String?> _getiOSFCMToken() async {
    try {
      // APNS token'ını al
      String? apnsToken = await msbService.getAPNSToken();

      if (apnsToken == null) {
        print('APNS token not available, waiting...');
        // Biraz bekle ve tekrar dene
        await Future.delayed(const Duration(seconds: 2));
        apnsToken = await msbService.getAPNSToken();
      }

      if (apnsToken != null) {
        print('APNS Token obtained: ${apnsToken.substring(0, 20)}...');

        // APNS token varsa FCM token'ını al
        String? fcmToken = await msbService.getToken();

        if (fcmToken != null) {
          print('FCM Token: ${fcmToken.substring(0, 20)}...');
          // Topic'e subscribe ol
          await msbService.subscribeToTopic(topic);
          print('Subscribed to topic: $topic');
          return fcmToken;
        } else {
          print('Failed to get FCM token');
          return null;
        }
      } else {
        print('APNS token still not available after retry');
        return null;
      }
    } catch (e) {
      print('Error getting iOS FCM token: $e');
      return null;
    }
  }

  Future<String?> _getAndroidFCMToken() async {
    try {
      String? token = await msbService.getToken();

      if (token != null) {
        print('FCM Token: ${token.substring(0, 20)}...');
        // Topic'e subscribe ol
        await msbService.subscribeToTopic(topic);
        print('Subscribed to topic: $topic');
        return token;
      } else {
        print('Failed to get FCM token');
        return null;
      }
    } catch (e) {
      print('Error getting Android FCM token: $e');
      return null;
    }
  }

  // Token refresh listener'ı ekle
  void setupTokenRefreshListener() {
    msbService.onTokenRefresh.listen((fcmToken) {
      print('FCM Token refreshed: ${fcmToken.substring(0, 20)}...');
      // Yeni token'ı sunucuna gönder
      _updateTokenOnServer(fcmToken);
    }).onError((err) {
      print('Error on token refresh: $err');
    });
  }

  Future<void> _updateTokenOnServer(String token) async {
    // Burada token'ı sunucuna gönderme işlemi yapılabilir
    print('Token updated on server: ${token.substring(0, 20)}...');
  }

  setNotificationsEnabled(bool enabled) {
    isNotificationsEnabled = enabled;
    print('Notifications enabled: $isNotificationsEnabled');
  }

  Future<void> showSuccess(
      {required String title, required String message}) async {
    if (isNotificationsEnabled) {
      print('Success notification shown: $title - $message');
      // Burada gerçek notification gösterme işlemi yapılabilir
    } else {
      print('Notifications are disabled');
    }
  }

  showError({required String title, required String message}) async {
    if (isNotificationsEnabled) {
      print('Error notification shown: $title - $message');
    } else {
      print('Notifications are disabled');
    }
  }

  showInfo({required String title, required String message}) async {
    if (isNotificationsEnabled) {
      print('Info notification shown: $title - $message');
    } else {
      print('Notifications are disabled');
    }
  }

  showWarning({required String title, required String message}) async {
    if (isNotificationsEnabled) {
      print('Warning notification shown: $title - $message');
    } else {
      print('Notifications are disabled');
    }
  }

  showCustomNotification(String title, String body) {
    if (isNotificationsEnabled) {
      print('Custom notification shown: $title - $body');
    } else {
      print('Notifications are disabled');
    }
  }

  Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');
  }

  Future<void> handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');
    print('Title: ${message.notification?.title}');
    print('Body: ${message.notification?.body}');
    print('Data: ${message.data}');

    // Foreground'da notification göster
    if (message.notification != null) {
      showCustomNotification(
        message.notification!.title ?? 'Notification',
        message.notification!.body ?? 'New message received',
      );
    }
  }

  Future<void> handleNotificationClick(RemoteMessage message) async {
    print('Notification clicked: ${message.messageId}');
    print('Data: ${message.data}');

    // Notification click handling - navigation vs. yapılabilir
    if (message.data.isNotEmpty) {
      _handleNotificationNavigation(message.data);
    }
  }

  void _handleNotificationNavigation(Map<String, dynamic> data) {
    // Notification data'ya göre sayfa yönlendirmesi yapılabilir
    print('Handling navigation with data: $data');

    if (data['screen'] != null) {
      // Navigator ile sayfa yönlendirmesi
      print('Navigating to screen: ${data['screen']}');
    }
  }

  Future<void> configureFCM() async {
    try {
      // Firebase Messaging yapılandırması
      FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
      FirebaseMessaging.onMessage.listen(handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(handleNotificationClick);

      // Token refresh listener'ını kur
      setupTokenRefreshListener();

      // FCM'i başlat
      String? token = await initFCM();

      if (token != null) {
        print('FCM configuration successful');
      } else {
        print('FCM configuration failed - no token received');
      }
    } catch (e) {
      print('Error configuring FCM: $e');
    }
  }

  Future<void> subscribeToTopic(String topicName) async {
    if (isNotificationsEnabled) {
      try {
        await msbService.subscribeToTopic(topicName);
        print('Subscribed to topic: $topicName');
      } catch (e) {
        print('Error subscribing to topic $topicName: $e');
      }
    } else {
      print('Notifications are disabled, cannot subscribe to topic');
    }
  }

  Future<void> unsubscribeFromTopic(String topicName) async {
    if (isNotificationsEnabled) {
      try {
        await msbService.unsubscribeFromTopic(topicName);
        print('Unsubscribed from topic: $topicName');
      } catch (e) {
        print('Error unsubscribing from topic $topicName: $e');
      }
    } else {
      print('Notifications are disabled, cannot unsubscribe from topic');
    }
  }

  // Token'ı tekrar almak için utility method
  Future<String?> refreshToken() async {
    try {
      if (Platform.isIOS) {
        return await _getiOSFCMToken();
      } else {
        return await _getAndroidFCMToken();
      }
    } catch (e) {
      print('Error refreshing token: $e');
      return null;
    }
  }

  // Notification permission durumunu kontrol et
  Future<AuthorizationStatus> getNotificationPermissionStatus() async {
    NotificationSettings settings = await msbService.getNotificationSettings();
    return settings.authorizationStatus;
  }
}
