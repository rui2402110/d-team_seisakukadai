import 'package:flutter/material.dart';
import 'component/navbar.dart';

class Setting extends StatefulWidget {
  const Setting({super.key});

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  @override
  Widget build(BuildContext context) {
    // ナビ付きの枠に、この画面の中身を渡す
    return const Navbar(
      selectedIndex: NavIndex.setting,
      child: Center(
        child: Text("設定画面"),
      ),
    );
  }
}
