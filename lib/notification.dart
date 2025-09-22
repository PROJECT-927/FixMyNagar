import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();

    // ✅ Initialize Awesome Notifications
    AwesomeNotifications().initialize(
      null, // null = default app icon
      [
        NotificationChannel(
          channelKey: 'civic_channel',
          channelName: 'Civic Alerts',
          channelDescription: 'Notifications about nearby civic issues',
          defaultColor: Colors.red,
          importance: NotificationImportance.High,
          channelShowBadge: true,
        ),
      ],
    );

    // ✅ Ask for permission if not already allowed
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  void _showNotification(String title, String body) {
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: DateTime.now().millisecondsSinceEpoch.remainder(100000), // unique id
        channelKey: 'civic_channel',
        title: title,
        body: body,
        notificationLayout: NotificationLayout.Default,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notification Test")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _showNotification(
              "⚠️ Pothole Nearby",
              "There’s a pothole within 100 meters near MG Road!",
            );
          },
          child: const Text("Send Test Notification"),
        ),
      ),
    );
  }
}
