import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:push_notifications/notifications_services.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  FirebaseNotificationsServices notificationsServices =
      FirebaseNotificationsServices();
  @override
  void initState() {
    super.initState();
    notificationsServices.requestNotificationPermission();

    notificationsServices.firebaseinit(context);
    notificationsServices.setupInteractMessage(context);
    notificationsServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('Device token : $value');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView(
        children: [
          TextButton(onPressed: () {}, child: Text("Send notification")),
        ],
      ),
    );
  }
}
