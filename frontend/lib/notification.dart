import 'package:flutter/material.dart';
import 'component/navbar.dart';

class UserNotification extends StatefulWidget {
  const UserNotification({super.key});

  @override
  State<UserNotification> createState() => _UserNotificationState();
}

class _UserNotificationState extends State<UserNotification> {
  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return const Navbar(
      selectedIndex: NavIndex.notification,
      child: Center(
        child: Text("通知画面"),
      ),
    );
  }
}
