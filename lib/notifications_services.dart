// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'dart:math';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:push_notifications/message_screen.dart';

class FirebaseNotificationsServices {
  final FirebaseMessaging messaging = FirebaseMessaging.instance;

  //flutterlocal notification plugin is used to show message on screen as notification
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  //first get notification permission from app user
  //it ask the app user to turn on notifications and off on device
  void requestNotificationPermission() async {
    NotificationSettings notificationSettings = await messaging
        .requestPermission(
          alert: true,
          announcement: true,
          badge: true,
          carPlay: true,
          criticalAlert: true,
          sound: true,
          providesAppNotificationSettings: true,
        );

    if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print("Notification Permission granted");
      }
    } else if (notificationSettings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      if (kDebugMode) {
        print("Notifications permission provisional");
      }
    } else {
      if (kDebugMode) {
        print("Notifications permission denied");
      }
    }
  }

  //get device token to send notification
  //dvice token is important to send notification on device if it is not correct notification will not be sent to specific user
  Future getDeviceToken() async {
    final String? token = await messaging.getToken();
    return token;
  }

  //refresh device token if device token expires and any other thing occur
  void refreshDeviceToken() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

  //next all work be to show message on screen

  //firebase init function
  //using this function we get message title,body , data  etc on console screeen
  //here we call show notification function becuase this function get notification details and to display notification detail on screen we will pass show notification function here
  void firebaseinit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      if (kDebugMode) {
        print('Message title ${message.notification?.title}');
      }
      if (kDebugMode) {
        print('Message body ${message.notification?.body}');
      }
      if (kDebugMode) {
        print('Message data ${message.data}');
      }
      if (Platform.isAndroid) {
        initLocalNotification(context, message);
        showNotification(message);
      } else {
        showNotification(message);
      }
    });
  }

  void initLocalNotification(
    BuildContext context,
    RemoteMessage message,
  ) async {
    var androidInitialization = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var iosInitialization = DarwinInitializationSettings();
    var initializationSettings = InitializationSettings(
      iOS: iosInitialization,
      android: androidInitialization,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (payLoad) {
        handleMessage(context, message);
      },
    );
  }

  //show notification on mobile screen as notification
  //we will need android and ios notification details
  Future showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
      Random.secure().nextInt(10000).toString(),
      'High importance message',
      importance: Importance.max,
    );

    //android notification details
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          channel.id.toString(),
          channel.name.toString(),
          channelDescription: 'Channel description',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );
    //ios notification detail
    DarwinNotificationDetails iosInitializationdetails =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );
    //notification details pass both android and ios notification details
    NotificationDetails notificationDetails = NotificationDetails(
      iOS: iosInitializationdetails,
      android: androidNotificationDetails,
    );
    Future.delayed(Duration.zero, () {
      _flutterLocalNotificationsPlugin.show(
        0,
        message.notification?.title,
        message.notification?.body,
        notificationDetails,
      );
    });
  }

  //function to move user from notification tap to the desired screen based on notification payload
  // (payload means data having key , value pairs and based on these keys we decide where to move on tap)
  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data['type'] == 'msg') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return MessageScreen();
          },
        ),
      );
    }
  }

  //function to move user from notification tap to desired notification page when app is in background or killed
  Future<void> setupInteractMessage(BuildContext context) async {
    //when app is terminated
    RemoteMessage? initalMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initalMessage != null) {
      handleMessage(context, initalMessage);
    }
    //when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }
}
