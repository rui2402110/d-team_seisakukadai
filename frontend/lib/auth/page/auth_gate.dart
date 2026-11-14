import 'package:flutter/material.dart';

import '../../timeline/page/timeline_page.dart';
import '../repository/auth_repository.dart';
import 'auth_page.dart';

/// アプリ起動直後の分かれ道
/// ログイン済みならタイムライン、未ログインなら認証の入口(AuthPage)を表示する
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  // 起動時に1回だけ判定する(画面が作り直されても、判定をやり直さない)
  late final Future<bool> _signedIn;

  @override
  void initState() {
    super.initState();
    _signedIn = AuthRepository().isSignedInAtStart();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _signedIn,
      builder: (context, snapshot) {
        // 判定中
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // ログイン済みならタイムライン、そうでなければ入口の画面
        return snapshot.data == true ? const Timeline() : const AuthPage();
      },
    );
  }
}
