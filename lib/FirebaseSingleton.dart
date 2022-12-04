import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FirebaseSingleton {
  late AndroidNotificationChannel channel;

  bool isFlutterLocalNotificationsInitialized = false;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  static FirebaseSingleton? _instance;

  FirebaseSingleton._() {
    print(" in initialization");
    // initialization and
    if (isFlutterLocalNotificationsInitialized) {
      return;
    }

    initialiseNotification();

    FirebaseMessaging.onMessage.listen(showFlutterNotification);
  }

  void showFlutterNotification(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null && android != null) {
      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channel.id,
            channel.name,
            channelDescription: channel.description,
            icon: 'launch_background',
          ),
        ),
      );
    }
  }

  initialiseNotification() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print(" token $token");
    channel = const AndroidNotificationChannel(
      'channel_id', // id
      'Notification Title', // title
      description: 'Notification description', // description
      importance: Importance.high,
    );

    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    isFlutterLocalNotificationsInitialized = true;
  }

  factory FirebaseSingleton() {
    _instance ??= FirebaseSingleton._();
    // since you are sure you will return non-null value, add '!' operator
    return _instance!;
  }
}
