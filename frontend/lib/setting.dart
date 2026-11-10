import 'package:flutter/material.dart';
import 'component/navbar.dart';

class Setting extends StatefulWidget {
  @override
  _SettingState createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text("設定画面")
      );
  }
}
