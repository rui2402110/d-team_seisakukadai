import 'package:flutter/material.dart';

import '../../core/kakko_theme.dart';
import '../widget/auth_widgets.dart';
import 'login_page.dart';
import 'register_page.dart';

/// 入口の画面 認証方法を選択するための画面
class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      children: [
        Text(
          '好きな作品ごとにコミュニティをつくって、\n感想を語り合おう',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            height: 1.6,
            color: KakkoColors.muted,
          ),
        ),
        const SizedBox(height: 26),
        AuthButton(
          label: 'ログイン',
          // ログイン画面へ遷移
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const LoginPage()),
          ),
        ),
        const SizedBox(height: 12),
        AuthButton(
          label: '新規登録',
          primary: false,
          // 新規登録画面へ遷移
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const RegisterPage()),
          ),
        ),
      ],
    );
  }
}
